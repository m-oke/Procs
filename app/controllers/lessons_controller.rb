class LessonsController < ApplicationController
  before_action :set_lesson, only: [:show, :questions, :students]
  before_filter :authenticate_user!
  def index
    @question = Question.new
    @sample = Sample.new
    @test_data = TestDatum.new
  end
  def show
    @teachers = get_teachers
  end

  def students
    @students = get_students
  end

  private
  def set_lesson
    @lesson = Lesson.find(params[:lesson_id])
  end

  def get_students
    return User.where(:id => @lesson.user_lessons.where(:is_teacher => false).pluck(:user_id))
  end

  def get_teachers
    return User.where(:id => @lesson.user_lessons.find_by(:is_teacher => true).pluck(:user_id))
  end
end
