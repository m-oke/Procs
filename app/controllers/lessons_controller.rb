class LessonsController < ApplicationController
  before_action :set_lesson, only: [:show, :questions]
  before_action :init

  def index
    @lesson = Lesson.new
  end

  def new
  end

  #　クラスの作成
  def create
    # @lesson = Lesson.new(params[:lesson])
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
        @user_lesson.is_teacher = TRUE
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

  def show
    @teachers = User.where(:id => @lesson.user_lessons.find_by(:is_teacher => true).user_id)
  end

  def questions
    @questions = @lesson.question
    render 'questions'
  end

  #Luhnアルゴリズムの導入
  def init
    require 'luhn'
  end

  private
  def set_lesson
    @lesson = Lesson.find(params[:id])
  end

  def params_lesson
    params.require(:lesson).permit(:name , :description)
  end
end
