# -*- coding: utf-8 -*-
class LessonsController < ApplicationController
  #bing
  require 'searchbing'
  APIKEY = "b03khzsJqXejAfMS3U1ik0lC2Ryd5lnhKu/wZEXaOAc"
  #google
  require 'addressable/uri'
  require 'json'
  require 'net/http/persistent'
  GOOGLE_API_KEY = 'AIzaSyAPy05rFWhHMEpOXUbiJ1rgt4ygEOqJHGw'
  GOOGLE_ENGINE_ID = '006988608042267398432:yloxhbwl0zk'
  before_action :check_lesson, only: [:show, :students]
  before_filter :authenticate_user!
  before_action :init

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
    #get data from ajax
    @question_id = params[:question_id]
    @student_id = params[:student_id]
    @lesson_id = params[:student_id]

    @question = Question.find_by(:id => @question_id)
    @answer = Answer.where(:lesson_id => @lesson_id, :student_id => @student_id, :question_id => @question_id).last

    if(@question_id.to_i == 1)
      search_query = "人工知能"
    elsif(@question_id.to_i == 2)
      search_query = "常総市　鬼怒川"
    else
      search_query = "筑波大学"
    end
    bing = Bing.new(APIKEY, 10, 'Web')
    @results = bing.search(search_query)

    @search_url = "https://www.googleapis.com/customsearch/v1?key=#{GOOGLE_API_KEY}&cx=#{GOOGLE_ENGINE_ID}&q=#{search_query}"
    @uri = Addressable::URI.parse(@search_url)
    g_result = JSON.parse(Net::HTTP.get(@uri))
    puts g_result
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
end
