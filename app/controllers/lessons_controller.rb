# -*- coding: utf-8 -*-
class LessonsController < ApplicationController
  before_action :check_lesson, only: [:show, :students]
  before_filter :authenticate_user!
  before_action :init

  require 'addressable/uri'
  #bing
  APIKEY = "b03khzsJqXejAfMS3U1ik0lC2Ryd5lnhKu/wZEXaOAc"
  #google
  GOOGLE_API_KEY = 'AIzaSyAPy05rFWhHMEpOXUbiJ1rgt4ygEOqJHGw'
  GOOGLE_ENGINE_ID = '006988608042267398432:yloxhbwl0zk'

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
    search_limit = 5
    @rr = ''
    #get data from ajax
    @question_id = params[:question_id]
    @student_id = params[:student_id]
    @lesson_id = params[:lesson_id]

    @question = Question.find_by(:id => @question_id)
    @answer = Answer.where(:lesson_id => @lesson_id, :student_id => @student_id, :question_id => @question_id).last

    fullPathName = UPLOADS_ANSWERS_PATH.join(@student_id.to_s, @lesson_id.to_s, @question_id.to_s).to_s + '/' + @answer.file_name

    arrayReturn = get_keyword_from_source(fullPathName)
    keywordContent=arrayReturn.sort do |item1,item2|
      item2.length <=>item1.length
    end

    #bing = Bing.new(APIKEY, 10, 'Web')
    #@results = bing.search(search_query)


    # @search_url = "https://www.googleapis.com/customsearch/v1?key=#{GOOGLE_API_KEY}&cx=#{GOOGLE_ENGINE_ID}&q=#{search_query}"
    # uri = Addressable::URI.parse(@search_url)
    # @g_results = JSON.parse(Net::HTTP.get(uri))

    if keywordContent.size < search_limit
      search_limit = keywordContent.size
    end
    # num = 0
    # temp_keyword = ''
    # while search_limit > 0 do
    #   search_keyword = keywordContent[num]
    #   search_keyword = search_keyword + ' ' + temp_keyword
    #   temp_keyword = search_keyword
    #   search_keyword = google_keyword_processing(search_keyword)
    #   search_url = "https://www.googleapis.com/customsearch/v1?key=#{GOOGLE_API_KEY}&cx=#{GOOGLE_ENGINE_ID}&q=#{search_keyword}"
    #   pp search_url
    #   search_url = URI.encode(search_url)
    #   uri = URI.parse(search_url)
    #   g_results = JSON.parse(Net::HTTP.get(uri))
    #   g_results['items'].each do |item|
    #     title = item['title']
    #     link = item['link']
    #     nSize = @result.size
    #     if nSize == 0
    #       @result.push([title,link,1])
    #     else
    #       nMark = -1
    #       for n in 0..nSize-1
    #         if @result[n][1]==link
    #           nMark = n
    #         end
    #       end
    #       if nMark != -1
    #         @result[nMark][2] = @result[nMark][2] + 1
    #       else
    #         @result.push([title,link,1])
    #       end
    #     end
    #   end
    #   search_limit = search_limit - 1
    #   num = num + 1
    # end

    num = 0
    old_keyword = ''
    while search_limit > 0 do
      search_keyword = keywordContent[num]
      if old_keyword != ''
        search_keyword = old_keyword + 'bing_search' +  search_keyword
      end
      old_keyword = search_keyword
      search_keyword = bing_keyword_processing(search_keyword , 'bing_search')

      # bing = Bing.new(APIKEY, 10, 'Web')
      #
      # b_results = bing.search(search_keyword)
      pp search_keyword
      b_results = bing_search_json(search_keyword)
      if b_results.length != 0
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
        pp 'internet check is failed '
        break
      end
      search_limit = search_limit - 1
      num = num + 1
    end
    @result = @result.sort do |item1,item2|
      item2[2]<=> item1[2]
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
        end

        if line.size>0
          a.push(line)
        end
      end
    end
    File.delete(copyFullPath)
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

  def google_keyword_processing(keyword)
    #delete " " symbol code
    while keyword.include?('"') do
      keyword = keyword.sub(/"/,' ')
    end
    return 'jolly jumpers problem ' +keyword
  end

  def bing_search_json(search_word, offset = 0)

    user = ''
    account_key = APIKEY
    num_results= 10.to_s
    web_search_url = "https://api.datamarket.azure.com/Bing/Search/v1/Composite?Sources="
    sources_portion = URI.encode_www_form_component('\'' + 'Web' + '\'')
    query_string = '&$format=json&Query='
    query_portion = URI.encode_www_form_component('\'' + search_word + '\'')
    params = "&$top=#{num_results}&$skip=#{offset}"

    full_address = web_search_url + sources_portion + query_string + query_portion + params

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
          result_set = []
      end
    rescue => e
      puts [uri.to_s, e.class, e].join(" : ")
      result_set = []
    end

  end

  def bing_keyword_processing(keyword , word)
    temp_keyword = ''
    if keyword.include?(word)
      keyword = keyword.split(word)
      keyword.each do |temp|
        temp_keyword = temp_keyword + "\"#{temp}\"" + ' '
      end
      return "\"jolly jumpers problem\"" + ' ' + temp_keyword
    else
      return "\"jolly jumpers problem\"" + ' ' + "\"#{keyword}\""
    end
  end

end