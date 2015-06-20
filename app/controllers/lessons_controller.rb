class LessonsController < ApplicationController
  def index
    @question = Question.new
    @sample = Sample.new
  end
end
