# -*- coding: utf-8 -*-
class QuestionsController < ApplicationController
  before_action :check_question, only: [:show]
  before_action :check_lesson, only: [:index, :new]
  before_filter :authenticate_user!

  # get '/quesions' || get '/lessons/:lesson_id/questions'
  # 問題一覧を表示
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Quesionのid
  def index
    id = params[:lesson_id] || 1
    params[:lesson_id] = id
    @lesson = Lesson.find_by(:id => id)
    @is_teacher = @lesson.user_lessons.find_by(:user_id => current_user.id).is_teacher
    @questions = @lesson.question

  end

  def new
    @question = Question.new
    @question_id = Question.count
    @question.samples.build
    @question.test_data.build
    @question.lesson_questions.build
    @lesson_id = params[:lesson_id].to_i
  end

  def create
    @lesson_id = params[:lesson_id]

    # アップロードされたテストデータを取得
    # TestDatumモデルにはファイル名を入力
    test_data = {}
    params['question']['test_data_attributes'].each.with_index(1) do |(key, val), i|
      files = {}
      files['input'] = val['input']
      files['output'] = val['output']
      if files['input'].size > 10.megabyte || files['output'].size > 10.megabyte
        flash[:alert] = 'ファイルサイズは10MBまでにしてください。'
        redirect_to new_lesson_question_path(:lesson_id => @lesson_id) and return
      end
      val['input'] = "input#{i}"
      val['output'] = "output#{i}"
      test_data["#{i}"] = files
    end

    @question = Question.new(question_params)
    if @question.save
      flash.notice='問題を登録しました'

      # ajax用の変数
      params[:lesson_id] = @lesson_id
      @lesson = Lesson.find_by(:id => @lesson_id)
      @questions = @lesson.question
      @is_teacher = Lesson.find_by(:id => @lesson_id).user_lessons.find_by(:user_id => current_user.id, :lesson_id => @lesson_id).is_teacher

      # テストデータのディレクトリを作成
      uploads_test_data_path = UPLOADS_QUESTIONS_PATH.join(@question.id.to_s)
      FileUtils.mkdir_p(uploads_test_data_path) unless FileTest.exist?(uploads_test_data_path)

      # テストデータの保存
      test_data.each do |key, val|
        File.open("#{uploads_test_data_path}/input#{key}", "wb") do |f|
          f.write(val['input'].read)
        end
        File.open("#{uploads_test_data_path}/output#{key}", "wb") do |f|
          f.write(val['output'].read)
        end
      end

      flash.notice = '問題を登録しました'
    else
      flash.notice='問題の登録に失敗しました'
    end
  end

  # get '/lessons/:lesson_id/questions/:question_id'
  # 問題詳細を表示
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Questionのid
  def show
    @question = Question.find_by(:id => params[:question_id])
    lesson_id = params[:lesson_id] || 1
    @lesson = Lesson.find_by(:id => lesson_id)
    @latest_answer = Answer.latest_answer(:student_id => current_user.id,
                                          :question_id => params[:question_id],
                                          :lesson_id => lesson_id) || nil
    @is_teacher = UserLesson.find_by(:user_id => current_user.id, :lesson_id => lesson_id).is_teacher
    if @is_teacher
      @students = User.where(:id => @lesson.user_lessons.where(:is_teacher => false).pluck(:user_id))
    else
      @languages = LANGUAGES.map { |val| [val, val.downcase] }.to_h
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
      samples_attributes: [:question_id, :input, :output, :_destroy],
      test_data_attributes: [:question_id, :input, :output, :_destroy],
      lesson_questions_attributes: [:lesson_id, :question_id, :start_time, :end_time, :_destroy]
    )
  end

  # 該当する問題が存在するかどうか
  # @param [Fixnum] lesson_id
  # @param [Fixnum] question_id
  def check_question
    lesson_id = params[:lesson_id] || 1
    question_id = params[:question_id]
    return unless access_question_check(:user_id => current_user.id, :lesson_id => lesson_id, :question_id => question_id)
    @quesions = Question.find_by(:id => question_id)
  end

  # 該当する授業が存在するかどうか
  # @param [Fixnum] lesson_id
  # @param [Fixnum] question_id
  def check_lesson
    id = params[:lesson_id] || 1
    return unless access_lesson_check(:user_id => current_user.id, :lesson_id => id)
  end
end
