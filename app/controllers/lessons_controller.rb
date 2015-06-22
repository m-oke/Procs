class LessonsController < ApplicationController
  before_action :set_lesson, only: [:show, :questions]

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
