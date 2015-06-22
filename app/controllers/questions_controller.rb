class QuestionsController < ApplicationController
  def index
    params[:lesson_id] ? @lesson = Lesson.find(params[:lesson_id]) : @lesson = nil
    @lesson ? @questions = @lesson.question : @questions = Question.all
  end

end
