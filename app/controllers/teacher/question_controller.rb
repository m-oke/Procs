class Teacher::QuestionController < ApplicationController
  def questions
    render action: 'questions'
  end
end
