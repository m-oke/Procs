# -*- coding: utf-8 -*-
class QuestionsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @lesson = nil
    if params[:lesson_id]
      @lesson = Lesson.find(params[:lesson_id])
      ul = UserLesson.find_by(:user_id => current_user.id, :lesson_id => @lesson.id)
      if ul.nil?
        redirect_to root_path, :alert => "該当する授業に参加していません．"
      end
    end

    @lesson ? @questions = @lesson.question : @questions = Question.all
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

  private
  def question_params
    params.require(:question).permit(
        :title,
        :content,
        :input_description,
        :output_description,
        :run_time_limit,
        :memory_usage_limit,
        :cpu_usage_limit,
        samples_attributes: [input,output],
        test_data_attributes: [input,output]
    )

  end

end
