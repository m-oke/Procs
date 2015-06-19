class LessonsController < ApplicationController
  def index
    @question = Question.new
  end
end
