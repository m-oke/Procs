class QuestionsController < ApplicationController

  def index

  end
  def new

  end

  def create
    @question = Question.new(:title => params[:question][:title])
    if @question.save
      flash.notice='問題登録しました'
      redirect_to :controller => 'lessons', action:'index'
    else
      redirect_to :controller => 'lessons', action:'index'
    end
  end
end
