class QuestionsController < ApplicationController

  def index

  end
  def new

  end

  def create
    @question = Question.new(params[:question])
    @sample = Sample.new(params[:sample])
    @test_data = TestDatum.new(params[:test_data])

    if @question.save
      flash.notice='問題登録しました'
      redirect_to :controller => 'lessons', action:'index'
    else
      redirect_to :controller => 'lessons', action:'index'
    end
  end
end
