# -*- coding: utf-8 -*-
class QuestionsController < ApplicationController
  before_action :exclude_lesson_one
  before_filter :authenticate_user!

  # get '/quesions' || get '/lessons/:lesson_id/questions'
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Quesionのid
  def index
    id = params[:lesson_id] || 1
    @lesson = Lesson.find_by(:id => id)
    unless @lesson.nil?
      if UserLesson.find_by(:user_id => current_user.id, :lesson_id => id).nil?
        redirect_to root_path, :alert => '該当する授業に参加していません．' and return
      end
      @questions = @lesson.question
    else
      redirect_to root_path, :alert => '該当する授業が存在しません。' and return
    end
    @is_teacher = Lesson.find_by(:id => id).user_lessons.find_by(:user_id => current_user.id, :lesson_id => id).is_teacher
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

  # get '/lessons/:id'
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Questionのid

  def show
    @question = Question.find_by(:id => params[:id])
    lesson_id = params[:lesson_id] || 1
    if @question.nil? || LessonQuestion.find_by(:question_id => params[:id], :lesson_id => lesson_id).nil?
      redirect_to lessons_path, :alert => '該当する問題が存在しません。' and return
    end
    @latest_answer = Answer.latest_answer(:student_id => current_user.id,
                                          :question_id => params[:id],
                                          :lesson_id => lesson_id) || Answer.new
    @is_teacher = Lesson.find_by(:id => lesson_id).user_lessons.find_by(:user_id => current_user.id, :lesson_id => lesson_id).is_teacher
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

  # lesson_id == 1の場合は表示しない
  # @param [Fixnum] lesson_id
  def exclude_lesson_one
    if params[:lesson_id] == "1"
      redirect_to root_path, :alert => "該当する授業が存在しません。"
    end
  end


end
