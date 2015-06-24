class LessonsController < ApplicationController
  def index
    @question = Question.new
    @question.samples.build
    @question.test_data.build

  end
end
