class LessonsController < ApplicationController
  before_action :set_lesson, only: [:show, :questions]

  def show
    @teachers = @lesson.user.where(role: 0)
  end

  def questions
    @questions = @lesson.questions
    render 'questions'
  end

  private
  def set_lesson
    @lesson = Lesson.find(params[:id])
  end
end
