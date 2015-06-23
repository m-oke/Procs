class LessonsController < ApplicationController
  before_action :set_lesson, only: [:show, :questions]

  def index
    @lesson = Lesson.new
  end

  def new
  end

  def create
    @lesson = Lesson.new(params[:lesson])

    if @lesson.save
      flash.notice = 'クラス作成しました！'
      redirect_to root_path
    # redirect_to :action => "/lessons"
    else
      render action: 'new'
    end

  end

  def show
    @teachers = User.where(:id => @lesson.user_lessons.find_by(:is_teacher => true).user_id)
  end

  def questions
    @questions = @lesson.question
    render 'questions'
  end

  private
  def set_lesson
    @lesson = Lesson.find(params[:id])
  end
end
