# -*- coding: utf-8 -*-
class QuestionsController < ApplicationController
  before_action :exclude_lesson_one
  before_filter :authenticate_user!

  # get '/quesions' || get '/lessons/:lesson_id/questions'
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Quesionのid
  def index
    id = params[:lesson_id] || 1
    params[:lesson_id] = params[:lesson_id] || 1
    @lesson = Lesson.find_by(:id => id)
    unless @lesson.nil?
      if @lesson.user_lessons.find_by(:user_id => current_user.id, :lesson_id => id).nil?
        redirect_to root_path, :alert => '該当する授業に参加していません．' and return
      end
      @is_teacher = @lesson.user_lessons.find_by(:user_id => current_user.id).is_teacher
      @questions = @lesson.question
    else
      redirect_to root_path, :alert => '該当する授業が存在しません。' and return
    end
  end

  def new
    @question = Question.new
    @question_id = Question.count
    @question.samples.build
    @question.test_data.build
    @question.lesson_questions.build
    @lesson_id = params[:lesson_id].to_i
    session[:lesson_id] = @lesson_id
  end

  def create
    @question = Question.new(question_params)
    @lesson_id = session[:lesson_id]
    if @question.save
      flash.notice = '問題を登録しました'
      redirect_to lesson_questions_path(:lesson_id => @lesson_id)
      session[:lesson_id] = nil
    else
      redirect_to new_lesson_question_path(:lesson_id => @lesson_id)
    end
  end

  # get '/lessons/:id'
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Questionのid
  def show
    @question = Question.find_by(:id => params[:id])
    lesson_id = params[:lesson_id] || 1
    @lesson = Lesson.find_by(:id => lesson_id)
    if @lesson.nil? || @lesson.user_lessons.find_by(:user_id => current_user.id).nil?
      redirect_to root_path, :alert => '該当する授業に参加していません．' and return
    elsif @question.nil? || @question.lesson_questions.find_by(:lesson_id => lesson_id).nil?
      redirect_to lessons_path, :alert => '該当する問題が存在しません。' and return
    end
    @latest_answer = Answer.latest_answer(:student_id => current_user.id,
                                          :question_id => params[:id],
                                          :lesson_id => lesson_id) || nil
    @is_teacher = UserLesson.find_by(:user_id => current_user.id, :lesson_id => lesson_id).is_teacher
    @languages = LANGUAGES.map { |val| [val, val.downcase] }.to_h
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
      samples_attributes: [:question_id,:input,:output,:_destroy],
      test_data_attributes: [:question_id,:input,:output,:_destroy],
      lesson_questions_attributes: [:lesson_id,:question_id,:start_time,:end_time,:_destroy]
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
