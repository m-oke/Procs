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
    @question = Question.new
    @question.samples.build
    @question.test_data.build
  end


  def create
    @question = Question.new(question_params)

    if @question.save
      flash.notice='問題登録しました'
      redirect_to controller: 'lessons', action:'index'
    else
      redirect_to controller: 'lessons', action:'new'
    end
  end

  def show
    @question = Question.find(params[:id])
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
      samples_attributes: [:input,:output,:_destroy],
      test_data_attributes: [:input,:output,:_destroy]
    )
  end


end
