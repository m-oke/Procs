# -*- coding: utf-8 -*-
class LessonsController < ApplicationController
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

        flash.notice = 'クラスを作成しました！'
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

  def edit
    lesson_id = params[:id]
    @lesson = Lesson.find(lesson_id)
  end

  def update
    lesson_id = params[:id]
    lesson = Lesson.find(lesson_id)
    lesson['name'] = params[:lesson]['name']
    lesson['description'] = params[:lesson]['description']
    if lesson.save
      flash.notice = '授業を更新しました'
    else
      flash.notice = '授業の更新に失敗しました'
    end
    redirect_to  root_path

  end

  # get '/lessons/:id'
  def show
    @teachers = get_teachers
    @is_teacher = @lesson.user_lessons.find_by(:user_id => current_user.id, :lesson_id => @lesson.id).is_teacher
    session[:lesson_id] = params[:id] || session[:lesson_id]
  end

  # get '/lessons/:id/students'
  def students
    @students = get_students
    @lesson_questions_count = @lesson.lesson_questions.count
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
    @multi_check = 0
    #get data from ajax
    @question_id = params[:question_id]
    @student_id = params[:student_id]
    @lesson_id = params[:lesson_id]

    @question = Question.find_by(:id => @question_id)
    @lesson = Lesson.find_by(:id => @lesson_id)

    if @student_id.to_i != 0
      @student = User.find_by(:id => @student_id)
      answer = Answer.where(:lesson_id => @lesson_id, :student_id => @student_id, :question_id => @question_id).last
      @check_result = InternetCheckResult.where(:answer_id => answer.id)
      @check_result_count = @check_result.count
      if @check_result_count != 0
        return
      end
      init_result = InternetCheckResult.new(:answer_id => answer.id, :title => nil, :link => nil, :content => nil, :repeat => 0 )
      init_result.save
      single_check = PlagiarismInternetCheck.new(@question_id, @lesson_id, @student_id, @result)
      single_check.check
    else
      @students = User.where(:id => @lesson.user_lessons.where(:is_teacher => false).pluck(:user_id))
      @multi_check = 1
      @students.each do |s|
        answer = Answer.where(:lesson_id => @lesson_id, :student_id => s['id'], :question_id => @question_id).last

        unless answer.nil?
          check_result = InternetCheckResult.where(:answer_id => answer.id)
          check_result_count = check_result.count
          if check_result_count == 0
            init_result = InternetCheckResult.new(:answer_id => answer.id, :title => nil, :link => nil, :content => nil, :repeat => 0 )
            init_result.save
          end
        end
      end
      InternetCheckJob.perform_later(@question_id,@lesson_id)
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

end
