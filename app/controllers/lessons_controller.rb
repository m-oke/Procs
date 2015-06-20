class LessonsController < ApplicationController
  def index
    @question = Question.new
    @sample = Sample.new
    @test_data = TestDatum.new
  end
end
