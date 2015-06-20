class LessonsController < ApplicationController
  def index
    @question = Question.new
    @sample = Sample.new
    @test_data = TestDatum.new
    @question.samples.build
    @question.test_data.build
  end
end
