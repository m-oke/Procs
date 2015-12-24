
class PlagiarismInternetCheck
  # bing  ch
  # APIKEY = "b03khzsJqXejAfMS3U1ik0lC2Ryd5lnhKu/wZEXaOAc"
  #bing jp
  # APIKEY = "i5VYh/f3nJeCmCdii54uu1WoNj7UevHEoby6feROsNY"
  APIKEY = ENV['BING_APIKEY']

  def initialize(question_id,lesson_id,student_id,lesson_question_id,result)

    @question_id = question_id
    @lesson_id = lesson_id
    @student_id = student_id
    @result = result
    @lesson_question_id = lesson_question_id
  end

  def check
    search_limit = 5
    http_error = 0
    question_keyword = ""
    question_keywords = QuestionKeyword.where(:question_id => @question_id)
    question_keywords.each do |k|
      question_keyword = question_keyword + " " + k['keyword']
    end
    answer = Answer.where(:lesson_id => @lesson_id, :student_id => @student_id, :question_id => @question_id, :lesson_question_id => @lesson_question_id).last
    extend_name = "solution"
    fullPathName = UPLOADS_ANSWERS_PATH.join(@student_id.to_s, @lesson_question_id.to_s).to_s + '/' + answer.file_name
    # csv_file_full_path = UPLOADS_ANSWERS_PATH.join(@student_id.to_s, @lesson_question_id.to_s).to_s + '/' + "search_keyword_#{question_keyword}_#{extend_name}.csv"
    # csv_file_full_path2 = UPLOADS_ANSWERS_PATH.join(@student_id.to_s, @lesson_question_id.to_s).to_s + '/' + "search_result_#{question_keyword}_#{extend_name}.csv"
    # CSV.open(csv_file_full_path,'wb') do |out|
    #   out << ["keyword","title","link","times"]
    # end

    nlen = answer.file_name.size
    if answer.file_name[nlen-2,nlen-1]=='.c' || answer.file_name[nlen-4,nlen-1]=='.cpp'
      arrayReturn = get_keyword_from_cpp_source(fullPathName)
    elsif answer.file_name[nlen-3,nlen-1] =='.py'
      arrayReturn = get_keyword_from_python_source(fullPathName)
    else
      arrayReturn = []
    end

    #sort the keyword by length
    unless arrayReturn.empty?
      keywordContent=arrayReturn.sort do |item1,item2|
        item2.length <=>item1.length
      end
    end
    # set the times for search
    if keywordContent.size < search_limit
      search_limit = keywordContent.size
    end

    num = 0
    web_total_zero = 0       #検索の結果でデータがない場合を集計する　５回データがない場合、検索結果は、
    pre_search_total = 1     #前回の検索の結果でデータがある場合、１を与える；前回の検索の結果がなかった場合、０を与える
    temp_keyword_csv = []
    old_keyword = ''
    while search_limit > 0 do
      search_keyword = keywordContent[num]

      # 前回検索結果がない場合、検索用キーワードの設定
      # question_keyword sourcecode1 sourcecode2 => question_keyword sourcecode1 sourcecode3
      if pre_search_total == 0 && old_keyword.present?
        if old_keyword.include?('bing_search')
          old_keyword = old_keyword[0..(old_keyword.rindex('bing_search')-1)]
        else
          old_keyword = ''
        end
        pre_search_total = 1
      end

      if old_keyword != ''
        search_keyword = old_keyword + 'bing_search' +  search_keyword
      end
      old_keyword = search_keyword

      search_keyword = bing_keyword_processing(question_keyword, search_keyword , 'bing_search')


      # bing = Bing.new(APIKEY, 10, 'Web',{:Market => 'ja-JP'})
      # bing = Bing.new(APIKEY, 10, 'Web')
      # pp search_keyword
      # binding.pry
      # b_results = bing.search(search_keyword)

      b_results = internet_search_json(search_keyword)
      # pp b_results
      # binding.pry

      # unless b_results.empty?
      unless b_results.nil?
        if b_results[0][:WebTotal].to_i != 0

          b_results[0][:Web].each do |page|
            title = page[:Title]
            link = page[:Url]
            content = page[:Description]

            # CSV.open(csv_file_full_path,'a') do |out|
            #   out << [search_keyword,title,link,1]
            # end

            nSize = @result.size
            if nSize == 0
              @result.push([title,link,1,content,question_keyword])
            else
              nMark = -1
              for n in 0..nSize-1
                if @result[n][1]==link
                  nMark =  n
                end
              end
              if nMark != -1
                @result[nMark][2] = @result[nMark][2] + 1
              else
                @result.push([title,link,1,content,question_keyword])
              end
            end
          end
        else
          pre_search_total = 0
          web_total_zero += 1
        end
      else
        pp 'internet check by bing is failed '
        http_error = 1
        break
      end
      search_limit = search_limit - 1
      num = num + 1
    end

    pre_store_result = InternetCheckResult.where(:answer_id => answer.id, :title => nil, :link => nil, :content => nil)
    if pre_store_result.present?
      pre_store_result.each do |item|
        item.destroy
      end
    end

    
    #通信エラー
    #:title => nil , :link => '', :content => ''
    if http_error == 1
      http_error_result = InternetCheckResult.new(:answer_id => answer.id, :title => nil , :link => '', :content => '', :repeat => 1, :key_word => question_keyword )
      http_error_result.save
      @result.push(['http_error','http_error',1,'http_error','http_error'])
      return
    end
    # sort @result by item[2]
    store_num = 1
    unless @result.empty?
      @result = @result.sort do |item1,item2|
        item2[2]<=> item1[2]
      end
      # write_search_results_log(csv_file_full_path2,@result,temp_keyword_csv)
      first_elem = @result.first
      # search_limit = 5
      # 5回の検索、毎回の検索結果はありません=>else ;　各LINK一回だけの場合　titleに’’を与える =>else
      if first_elem[2] > 1 && web_total_zero != 5
        @result.each do |r|
          if store_num >5
            break
          end
          internet_check_result = InternetCheckResult.new(:answer_id => answer.id, :title => r[0], :link => r[1], :repeat => r[2], :content => r[3], :key_word => r[4])
          internet_check_result.save
          store_num+=1
        end
      else
        no_good_result = InternetCheckResult.new(:answer_id => answer.id, :title => '' , :link => nil, :content => nil, :repeat => 1, :key_word => question_keyword)
        no_good_result.save
      end
    else
      no_good_result = InternetCheckResult.new(:answer_id => answer.id, :title => '' , :link => nil, :content => nil, :repeat => 1, :key_word => question_keyword )
      no_good_result.save
    end
  end

  # input file_path to get search key words from c/c++ source code
  def get_keyword_from_cpp_source(pathname)
    a = Array.new
    copyFullPath = pathname[0,pathname.rindex('/')] + '/temp'
    open(pathname) do |input|
      open(copyFullPath,"w") do |output|
        output.write(input.read)
      end
    end

    # delete block comment
    delete_block_comment(copyFullPath,'C/C++')

    File.open(copyFullPath) do |file|
      file.each do |line|
        # delete row comment  and delete left blank space
        if line[0,2] == '//'
          line = ''
        elsif line.include?('//') && line[0,2] != '//'
          line = line[0,line.index('//')].strip
        else
          line = line.strip
        end

        #delete other rows which not to use
        if line.size> 0
          #delete #include row , {row   }row else  continue break
          if line == '{' || line == '}' || line =='else' || line[0,8] == '#include'
            line =''
          end
          #delete int main()
          if (line[0,3] =='int' || line[0,4] == 'void')&& line.include?('main')
            #delete  long space between int and main
            tmp = line.sub(/\s+/,' ')
            if tmp.include?('int main')||tmp.include?('void main')
              line = ''
            end
          end
          #delete namespace if exist using namespace std
          if line[0,5]=='using' && line.include?('namespace')
            tmp = line.sub(/\s+/,' ')
            if tmp.include?('using namespace')
              line = ''
            end
          end
          # delete line which start with for
          if line[0,3] == 'for' && line.include?('for')
            tmp = line.sub(/\s+/,' ')
            if tmp.include?('for(') || tmp.include?('for (')
              line = ''
            end
          end
          # delete lines which only contain break or continue
          if line == 'break' || line == 'continue'
            line = ''
          end
          # delete printf scanf and cin cout
          if line[0,6] == 'printf'  || line[0,5] == 'scanf' || line[0,3] == 'cin' || line[0,4] == 'cout'
            tmp = line.sub(/\s+/,' ')
            if (tmp.include?('printf(') || tmp.include?('printf (')) ||
                (tmp.include?('scanf(') || tmp.include?('scanf (')) ||
                (tmp.include?('cin>>') || tmp.include?('cin >>')) ||
                (tmp.include?('cout<<') || tmp.include?('cout <<'))
              line = ''
            end
          end

          # delete { and } which like { a = cycle_length(n/2, ++i); return a; }
          if line.size>0
            a.push(line)
          end
        end
      end
    end
    # File.delete(copyFullPath)
    return a
  end

  # input file_path to get search key words from c/c++ source code
  def get_keyword_from_python_source(pathname)
    a = Array.new
    copyFullPath = pathname[0,pathname.rindex('/')] + '/temp'
    open(pathname) do |input|
      open(copyFullPath,"w") do |output|
        output.write(input.read)
      end
    end

    # delete block comment
    delete_block_comment(copyFullPath,'python')

    File.open(copyFullPath) do |file|
      have_multi_row = 0
      str_multi_row = ''
      file.each do |line|
        # delete row comment  and delete left blank space
        if line[0,1] == '#'
          line = ''
        elsif line.include?('#') && line[0,1] != '#'
          line = line[0,line.index('#')].strip
        else
          line = line.strip
        end

        #delete lines which used in many all source file
        if line.size>0
          #delete import ***
          # if line[0,6] == 'import' && line.include?('import')
          # from aaa import ***
          if line[0,7] == 'import ' || (line[0,5]== 'from ' &&line.include?('import'))
            line = ''
          end
          #delete if __name__ == "__main__":
          if line[0,3] == 'if ' && line.include?('__name__') && line.include?('"__main__"')
            tmp = line.sub(/\s+/,'')
            if tmp.include?('if__name__=="__main__":')
              line = ''
            end
          end
          # delete lines which only contain pass or  break or continue
          if line =='pass' || line == 'break' || line == 'continue'
            line = ''
          end
          #  delete lines whice like
          # print "----------------------------------"
          # print '================================='
          # print "===== class ====="
          # print "++++ list ++++"
          # use squeeze
          if line[0,6] == 'print '
            tmp = line.sub(/\s+/,' ')
            # if (tmp.include?('-') && tmp.length-tmp.squeeze('-').length > 6) ||
            #     (tmp.include?('+') && tmp.length-tmp.squeeze('+').length > 6) ||
            #     (tmp.include?('=') && tmp.length-tmp.squeeze('=').length > 6) ||
            #     (tmp.include?('*') && tmp.length-tmp.squeeze('*').length > 6) ||
            #     (tmp.include?('/') && tmp.length-tmp.squeeze('/').length > 6)
            #   line = ''
            # end
            if tmp.include?('print(') || tmp.include?('print (')
              line =''
            end
          end
          # delete try: except: finally:
          if line == 'try:' || line == 'except:' || line == 'finally:'
            line = ''
          end
        end

        # to deal with  """ used in string
        #  test_str =  """
        #              test1
        #              test2
        #              test3
        #              """
        if line.count('"""') == 1 && have_multi_row == 0
          have_multi_row = 1
          str_multi_row += (' '+ line)
          next
        end
        if have_multi_row == 1 && line.count('"""') == 0
          str_multi_row += (' '+ line)
          next
        end
        if have_multi_row == 1 && line.count('"""') == 1
          have_multi_row = 0
          str_multi_row += (' ' + line)
          line = str_multi_row
          str_multi_row = ''
        end

        if line.size>0
          a.push(line)
        end
      end
    end
    # File.delete(copyFullPath)
    return a
  end

  def delete_block_comment(pathname,language)
    file = File.open(pathname)
    content = file.read
    if language == 'C/C++'
      while content.index('*/')!= nil do
        end_num  = content.index('*/')
        start_num = content[0,end_num].rindex('/*')
        if end_num != nil && start_num != nil
          content = content[0,start_num]  + content[end_num+2,content.size-end_num-2]
        else
          break
        end
      end
    end
    if language == "python"
      comment_mark = "\'\'\'"
      while content.index(comment_mark)!= nil do
        len = content.size
        first_num  = content.index(comment_mark)
        if first_num != nil
          second_num = content[first_num+3,len-1].index(comment_mark)
          if second_num != nil
            content = content[0..first_num-1]  + content[first_num+second_num+6..len-1]
          end
        else
          break
        end
      end
    end
    File.write(pathname,content)
    file.close
  end

  def bing_keyword_processing(question_keyword, keyword , split_word)
    temp_keyword = ''
    if keyword.include?(split_word)
      keyword = keyword.split(split_word)
      keyword.each do |temp|
        temp_keyword = temp_keyword + "\"#{temp}\"" + ' '
      end
      # return "\"jolly jumpers problem\"" + ' ' + temp_keyword
      return "\"#{question_keyword}\"" + ' ' + temp_keyword
    else
      # return "\"jolly jumpers problem\"" + ' ' + "\"#{keyword}\""
      return "\"#{question_keyword}\"" + ' ' + "\"#{keyword}\""
    end
  end

  def internet_search_json(search_word)
    result_set = ''
    user = ''
    account_key = APIKEY
    # ja-JP and en-US
    market = 'en-US'
    num_results= 10.to_s
    web_search_url = "https://api.datamarket.azure.com/Bing/Search/v1/Composite?Sources="
    sources_portion = URI.encode_www_form_component('\'' + 'Web' + '\'')
    query_string = '&$format=json&Query='
    query_portion = URI.encode_www_form_component('\'' + search_word + '\'')
    query_market_string = '&Market='
    query_market_portion = URI.encode_www_form_component('\'' + market + '\'')
    params = "&$top=#{num_results}&$skip=#{0}"

    full_address = web_search_url + sources_portion + query_string + query_portion + query_market_string + query_market_portion + params
    pp full_address

    uri = URI(full_address)
    req = Net::HTTP::Get.new(uri.request_uri)
    req.basic_auth user, account_key
    begin
      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https'){|http|
        http.open_timeout = 3
        http.read_timeout = 6
        http.request(req)
      }
      case res
        when Net::HTTPSuccess
          body = JSON.parse(res.body, :symbolize_names => true)
          result_set = body[:d][:results]
        else
          puts [uri.to_s, res.value].join(" : ")
          result_set = nil
      end
    rescue => e
      puts [uri.to_s, e.class, e].join(" : ")
      result_set = nil
    end
    return result_set
  end

  def write_search_results_log(full_path,results,keywords)
    # File.delete(full_path)
    CSV.open(full_path,'w') do |out|
      out << ["title","link","times"]
      results.each do |r|
        out << [r[0],r[1],r[2]]
      end
      out << ["keyword"]
      keywords.each do |keyword|
        out << [keyword]
      end
    end
  end
end