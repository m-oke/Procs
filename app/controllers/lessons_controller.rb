# -*- coding: utf-8 -*-
class LessonsController < ApplicationController
  before_action :check_lesson, only: [:show, :students]
  before_filter :authenticate_user!
  before_action :init

  require 'addressable/uri'
  # bing  ch
  # APIKEY = "b03khzsJqXejAfMS3U1ik0lC2Ryd5lnhKu/wZEXaOAc"
  #bing jp
  APIKEY = "i5VYh/f3nJeCmCdii54uu1WoNj7UevHEoby6feROsNY"



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
    @result = Array.new(0,Array.new(4,0))
    search_limit = 5

    #get data from ajax
    @question_id = params[:question_id]
    @student_id = params[:student_id]
    @lesson_id = params[:lesson_id]

    @question = Question.find_by(:id => @question_id)
    @answer = Answer.where(:lesson_id => @lesson_id, :student_id => @student_id, :question_id => @question_id).last
    question_keyword = ""
    question_keywords = QuestionKeyword.where(:question_id => @question_id )
    question_keywords.each do |k|
      question_keyword = question_keyword + " " + k['keyword']
    end
    @check_result = InternetCheckResult.where(:answer_id => @answer.id)
    @check_result_count = @check_result.count
    if @check_result_count != 0
      return
    end

    fullPathName = UPLOADS_ANSWERS_PATH.join(@student_id.to_s, @lesson_id.to_s, @question_id.to_s).to_s + '/' + @answer.file_name
    csv_file_full_path = UPLOADS_ANSWERS_PATH.join(@student_id.to_s, @lesson_id.to_s, @question_id.to_s).to_s + '/' + 'search_result_log.csv'

    nlen = @answer.file_name.size
    if @answer.file_name[nlen-2,nlen-1]=='.c' || @answer.file_name[nlen-4,nlen-1]=='.cpp'
      arrayReturn = get_keyword_from_cpp_source(fullPathName)
    elsif @answer.file_name[nlen-3,nlen-1] =='.py'
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
    temp_keyword_csv = []
    old_keyword = ''
    while search_limit > 0 do
      search_keyword = keywordContent[num]
      if old_keyword != ''
        search_keyword = old_keyword + 'bing_search' +  search_keyword
      end
      old_keyword = search_keyword
      search_keyword = bing_keyword_processing(question_keyword, search_keyword , 'bing_search')
      bing = Bing.new(APIKEY, 10, 'Web')
      pp search_keyword
      b_results = bing.search(search_keyword)


      pp b_results
      # binding.pry
      # b_results = internet_search_json(search_keyword,'bing search')
      unless b_results.empty?
        b_results[0][:Web].each do |page|
          title = page[:Title]
          link = page[:Url]
          content = page[:Description]
          nSize = @result.size
          if nSize == 0
            @result.push([title,link,1,content])
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
              @result.push([title,link,1,content])
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

    # sort @result by item[2]
    unless @result.empty?
      @result = @result.sort do |item1,item2|
        item2[2]<=> item1[2]
      end
      write_search_results_log(csv_file_full_path,@result,temp_keyword_csv)
      @result.each_with_index(1) do |r,i|
        if i>5
          break
        end
        internet_check_result = InternetCheckResult.new(:answer_id => @answer.id, :title => r[0], :link => r[1], :repeat => r[2], :content => r[3])
        unless internet_check_result.save
          flash[:notice] = "Internet剽窃チェック結果の保存に失敗しました．" and return
        end
      end
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
            line = ''
          end
          # delete { and } which like { a = cycle_length(n/2, ++i); return a; }
        end

        if line.size>0
          a.push(line)
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
      file.each do |line|
        # delete row comment  and delete left blank space
        if line[0,1] == '#'
          line = ''
        elsif line.include?('#') && line[0,1] != '#'
          line = line[0,line.index('#')].strip
        else
          line = line.strip
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
    if language = 'C/C++'
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
    if language = "python"
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
      comment_mark = "\"\"\""
      while content.index(comment_mark)!= nil do
        len = content.size
        first_num  = content.index(comment_mark)
        second_num = content[first_num+3,len-1].index(comment_mark)
        if first_num != nil && second_num != nil
          content = content[0..first_num-1]  + content[first_num+second_num+6..len-1]
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

  def internet_search_json(search_word, search_type)
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
    # File.delete(full_path)
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