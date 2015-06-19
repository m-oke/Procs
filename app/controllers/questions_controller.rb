class QuestionsController < ApplicationController

  def index

  end
  def new

  end

  def create
    @question = Question.new(params[:question])
    if @question.save
      flash.notice='問題登録しました'
      render action:'new'
    else
      render action:'new'
    end
  end
end
