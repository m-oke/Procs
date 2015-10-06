# -*- coding: utf-8 -*-
class LessonsController < ApplicationController
  before_action :check_lesson, only: [:show, :students]
  before_filter :authenticate_user!
  before_action :init

  require 'addressable/uri'
  # #bing  ch
  # APIKEY = "b03khzsJqXejAfMS3U1ik0lC2Ryd5lnhKu/wZEXaOAc"
  #bing jp
  APIKEY = "i5VYh/f3nJeCmCdii54uu1WoNj7UevHEoby6feROsNY"
  #google
  GOOGLE_API_KEY = 'AIzaSyAPy05rFWhHMEpOXUbiJ1rgt4ygEOqJHGw'
  GOOGLE_ENGINE_ID = '006988608042267398432:yloxhbwl0zk'
  PROBLEM_KEY_WORD1 = "the 3n+1 problem"
  PROBLEM_KEY_WORD2 = "jolly jumpers problem"

  # get '/'
  def index
  end

  # get '/lessons/new'
  def new
    @lesson = Lesson.new

    #教師の資格があるかどうかを確認する
    unless(User.find_by(:id => current_user.id).has_role?(:teacher))
      redirect_to root_path, :alert => "あなたはこの権限がありません" and return
    end
  end

  # post '/lessons'
  # クラスの作成
  def create
    @lesson = Lesson.new(params_lesson)
    @user_lesson = UserLesson.new
    @user_lesson.user_id = current_user.id

    #誤り検出のアルゴリズムLuhnを使って授業コードを生成する
    lesson_code = Array.new(10) { rand(10) }.join
    lesson_code + Luhn.checksum(lesson_code).to_s

    @lesson.lesson_code = lesson_code

    if @lesson.name != ''
      if @lesson.save

        #Teacherの情報をuser_lessonに記入する
        @user_lesson.lesson_id = @lesson.id
        @user_lesson.is_teacher = true
        @user_lesson.save

        flash.notice = 'クラス作成しました！'
        redirect_to root_path
          # redirect_to :action => "/lessons"
      else
        render action: 'new'
      end
    else
      render action: 'new'
      flash.notice = 'クラス名を入力してください！'
    end
  end

  # get '/lessons/:id'
  def show
    @teachers = get_teachers
    @is_teacher = @lesson.user_lessons.find_by(:user_id => current_user.id, :lesson_id => @lesson.id).is_teacher
  end

  # get '/lessons/:id/students'
  def students
    @students = get_students
    @lesson_id = params[:lesson_id]
    @lesson_questions = LessonQuestion.where(:lesson_id => @lesson_id)
    @lesson_questions_count = @lesson_questions.count
  end

  # get '/lessons/:id/students/:student_id'
  def student
    @lesson_id = params[:lesson_id]
    @student_id = params[:student_id]
    @student = User.find_by(:id => @student_id )
    @lesson_questions = LessonQuestion.where(:lesson_id => @lesson_id)
  end

  # source code check through internet
  def internet_check
    @result = Array.new(0,Array.new(3,0))
    search_limit = 1

    #get data from ajax
    @question_id = params[:question_id]
    @student_id = params[:student_id]
    @lesson_id = params[:lesson_id]

    @question = Question.find_by(:id => @question_id)
    @answer = Answer.where(:lesson_id => @lesson_id, :student_id => @student_id, :question_id => @question_id).last

    fullPathName = UPLOADS_ANSWERS_PATH.join(@student_id.to_s, @lesson_id.to_s, @question_id.to_s).to_s + '/' + @answer.file_name
    csv_file_full_path = UPLOADS_ANSWERS_PATH.join(@student_id.to_s, @lesson_id.to_s, @question_id.to_s).to_s + '/' + 'search_result_log.csv'

    arrayReturn = get_keyword_from_source(fullPathName)
    keywordContent=arrayReturn.sort do |item1,item2|
      item2.length <=>item1.length
    end

    if keywordContent.size < search_limit
      search_limit = keywordContent.size
    end

    num = 0
    temp_keyword = ''
    temp_keyword_csv = []
    default_google_search_check = 1
    default_bing_search_check = 0
    keep_search_limit = search_limit
    # wordA AND ("wordB" or "wordC")
    if default_google_search_check ==2
      old_word_google = ''
      while search_limit > 0 do
        search_word = keywordContent[num]
        if old_word_google != ''
          search_word = old_word_google + 'google_search' + search_word
        end
        old_word_google = search_word
        search_keyword = google_keyword_processing(search_word,'google_search')
        temp_keyword_csv.push(search_keyword)
        pp search_keyword
        results_temp = GoogleCustomSearchApi.search(search_keyword)
        results_temp["items"].each do |item|
          title = item['title']
          link = item['link']
          nSize = @result.size
          if nSize == 0
            @result.push([title,link,1])
          else
            nMark = -1
            for n in 0..nSize-1
              if @result[n][1]==link
                nMark = n
              end
            end
            if nMark != -1
              @result[nMark][2] = @result[nMark][2] + 1
            else
              @result.push([title,link,1])
            end
          end
        end
        search_limit = search_limit - 1
        num = num + 1
      end
    end
    if default_google_search_check == 1
      old_word_google = ''
      while search_limit > 0 do
        search_word = keywordContent[num]
        if old_word_google != ''
          search_word = old_word_google + 'google_search' + search_word
        end
        old_word_google = search_word
        search_keyword = google_keyword_processing(search_word,'google_search')
        temp_keyword_csv.push(search_keyword)
        pp search_keyword
        g_results = internet_search_json(search_keyword,'google search')
        if g_results != 'HTTPError'
          if g_results['searchInformation']['totalResults'] != "0"
            g_results['items'].each do |item|
              title = item['title']
              link = item['link']
              nSize = @result.size
              if nSize == 0
                @result.push([title,link,1])
              else
                nMark = -1
                for n in 0..nSize-1
                  if @result[n][1]==link
                    nMark = n
                  end
                end
                if nMark != -1
                  @result[nMark][2] = @result[nMark][2] + 1
                else
                  @result.push([title,link,1])
                end
              end
            end
          end
        else
          num = 0
          temp_keyword = ''
          default_bing_search_check = 1
          search_limit = keep_search_limit
          pp 'internet check by google is failed'
          break
        end
        search_limit = search_limit - 1
        num = num + 1
      end
    end
    if default_bing_search_check == 1
      old_keyword = ''
      while search_limit > 0 do
        search_keyword = keywordContent[num]
        if old_keyword != ''
          search_keyword = old_keyword + 'bing_search' +  search_keyword
        end
        old_keyword = search_keyword
        search_keyword = bing_keyword_processing(search_keyword , 'bing_search')

        # bing = Bing.new(APIKEY, 10, 'Web')
        # b_results = bing.search(search_keyword)
        pp search_keyword
        b_results = internet_search_json(search_keyword,'bing search')
        if b_results!= 'HTTPError'
          b_results[0][:Web].each do |page|
            title = page[:Title]
            link = page[:Url]
            nSize = @result.size
            if nSize == 0
              @result.push([title,link,1])
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
                @result.push([title,link,1])
              end
            end
          end
        else
          pp 'internet check by bing is failed '
          break
        end
        search_limit = search_limit - 1
        num = num + 1
      end
    end
    # sort @result by item[2]
    if @result.size != 0
      @result = @result.sort do |item1,item2|
        item2[2]<=> item1[2]
      end
      write_search_results_log(csv_file_full_path,@result,temp_keyword_csv)
    end

  end

  #Luhnアルゴリズムの導入
  def init
    require 'luhn'
  end

  private

  # idまたはlesson_idから該当するLessonを検索
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id 一部のURLでのlesson_id
  def check_lesson
    id = params[:lesson_id] || params[:id]
    return unless access_lesson_check(:user_id => current_user.id, :lesson_id => id)
    @lesson = Lesson.find_by(:id => id)
  end

  # 該当するlessonに所属するstudentを取得
  def get_students
    return User.where(:id => @lesson.user_lessons.where(:is_teacher => false).pluck(:user_id))
  end

  # 該当するlessonに所属するteacherを取得
  def get_teachers
    return User.where(:id => @lesson.user_lessons.where(:is_teacher => true).pluck(:user_id))
  end

  def params_lesson
    params.require(:lesson).permit(:name , :description)
  end

  # input file_path to get search key words from source code
  def get_keyword_from_source(pathname)
    a = Array.new
    copyFullPath = pathname[0,pathname.rindex('/')] + '/temp'
    open(pathname) do |input|
      open(copyFullPath,"w") do |output|
        output.write(input.read)
      end
    end

    # delete block comment
    delete_block_comment(copyFullPath)

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
          #delete #include row , {rwo  }row else  continue break
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
          #using namespace std;
          if line[0,5]=='using' && line.include?('namespace')
            tmp = line.sub(/\s+/,' ')
            if tmp.include?('using namespace')
              line = ''
            end
          end
          if line[0,3] == 'for' && line.include?('for')
            line = ''
          end
        end

        if line.size>0
          a.push(line)
        end
      end
    end
    # File.delete(copyFullPath)
    return a
  end


  def delete_block_comment(pathname)
    file = File.open(pathname)
    content = file.read

    while content.index('*/')!= nil do
      end_num  = content.index('*/')
      start_num = content[0,end_num].rindex('/*')
      if end_num != nil && start_num != nil
        content = content[0,start_num]  + content[end_num+2,content.size-end_num-2]
      else
        break
      end
    end
    File.write(pathname,content)
    file.close
  end

  def google_get_json(url)
    result = []
    uri = Addressable::URI.parse(url)

    begin
      response = Net::HTTP.start(uri.host,use_ssl: uri.scheme == 'https') do |http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get(uri.request_uri)
      end
      binding.pry
      case response
        when Net::HTTPSuccess
          json = response.body
          result = JSON.parse(json)
        else
          result = []
      end
    rescue => e
      result = []
    end
    return result
  end

  def google_keyword_processing(keyword,split_word)
    # #delete " " symbol code
    # while keyword.include?('"') do
    #   keyword = keyword.sub(/"/,' ')
    # end
    # while keyword.include?('&') do
    #   keyword = keyword.sub(/&/,' ')
    # end
    # if keyword2 == ''
    #   return PROBLEM_KEY_WORD1 + ' ' + "\"#{keyword1}\""
    # else
    #   # return 'jolly jumpers problem ' +keyword
    #   while keyword2.include?('"') do
    #     keyword2 = keyword2.sub(/"/,' ')
    #   end
    #   return PROBLEM_KEY_WORD1 + ' ' + "(\"#{keyword1}\" OR \"#{keyword2}\")"
    # end
    temp_keyword = ''
    if keyword.include?(split_word)
      keyword = keyword.split(split_word)
      keyword.each do |temp|
        # temp_keyword = temp_keyword+ temp + ' '
        temp_keyword = temp_keyword+ "\"#{temp}\"" + ' '
      end
      # return "\"jolly jumpers problem\"" + ' ' + temp_keyword
      return PROBLEM_KEY_WORD1 + ' ' + temp_keyword
    else
      # return "\"jolly jumpers problem\"" + ' ' + "\"#{keyword}\""
      return PROBLEM_KEY_WORD1 + ' ' + keyword
    end
  end

  def bing_keyword_processing(keyword , split_word)
    temp_keyword = ''
    if keyword.include?(split_word)
      keyword = keyword.split(split_word)
      keyword.each do |temp|
        temp_keyword = temp_keyword + "\"#{temp}\"" + ' '
      end
      # return "\"jolly jumpers problem\"" + ' ' + temp_keyword
      return "\"#{PROBLEM_KEY_WORD1}\"" + ' ' + temp_keyword
    else
      # return "\"jolly jumpers problem\"" + ' ' + "\"#{keyword}\""
      return "\"#{PROBLEM_KEY_WORD1}\"" + ' ' + "\"#{keyword}\""
    end
  end

  def internet_search_json(search_word, search_type)
    # problem_key_word = 'jolly jumpers problem  ("A[abs(V[I]-V[I+1])] = 1" OR "if(!A[I]){")'
    problem_key_word = 'jolly jumpers problem  A[abs(V[I]-V[I+1])] = 1  if(!A[I])'
    search_word2 = 'A[abs(V[I]-V[I+1])] = 1'
    search_word_test = 'while(scanf("%d %d",n,m)==2)'
    if search_type == 'bing search'
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
    end
    if search_type == 'google search'
      # search_word = URI.encode(search_word)

      # search_word = URI.encode_www_form_component(search_word)
      # full_address = "https://www.googleapis.com/customsearch/v1?key=#{GOOGLE_API_KEY}&cx=#{GOOGLE_ENGINE_ID}&q=#{search_word}"
      search_word_test = URI.encode_www_form_component(search_word_test)
      search_word2 = URI.encode_www_form_component(search_word2)
      problem_key_word = URI.encode_www_form_component(problem_key_word)
      full_address = "https://www.googleapis.com/customsearch/v1?key=#{GOOGLE_API_KEY}&cx=#{GOOGLE_ENGINE_ID}&q=#{problem_key_word}+%2Dfiletype%3Apdf+%2Dfiletype%3Adoc"
      pp full_address
    end

    uri = URI(full_address)
    req = Net::HTTP::Get.new(uri.request_uri)
    if search_type == 'bing search'
      req.basic_auth user, account_key
    end
    begin
      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https'){|http|
        http.open_timeout = 3
        http.read_timeout = 6
        http.request(req)
      }
      case res
        when Net::HTTPSuccess
          if search_type == 'bing search'
            body = JSON.parse(res.body, :symbolize_names => true)
            result_set = body[:d][:results]
          else
            g_results = JSON.parse(res.body)

          end
        else
          puts [uri.to_s, res.value].join(" : ")
          result_set = 'HTTPError'
      end
    rescue => e
      puts [uri.to_s, e.class, e].join(" : ")
      result_set = 'HTTPError'
    end

  end

  def write_search_results_log(full_path,results,keywords)
    File.delete(full_path)
    CSV.open(full_path,'w') do |out|
      out << ["title","link","times"]
      results.each do |result|
        out << [result[0],result[1],result[2]]
      end
      out << ["keyword"]
      keywords.each do |keyword|
        out << [keyword]
      end
    end
  end

end