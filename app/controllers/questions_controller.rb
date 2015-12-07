# -*- coding: utf-8 -*-
class QuestionsController < ApplicationController
  before_action :check_question, only: [:show]
  before_action :check_lesson, only: [:index, :new]
  before_filter :authenticate_user!

  # get '/questions' || get '/lessons/:lesson_id/questions'
  # 問題一覧を表示
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Questionのid
  def index
    lesson_id = params[:lesson_id] || session[:lessson_id] || 1
    session[:lesson_id] = lesson_id
    @lesson = Lesson.find_by(:id => lesson_id)
    @is_teacher = @lesson.user_lessons.find_by(:user_id => current_user.id).is_teacher
    @questions = @lesson.lesson_questions
  end

  def new
    @question = Question.new
    @question_id = Question.count
    @question.samples.build
    @question.test_data.build
    @question.lesson_questions.build
    @question.question_keywords.build
    @lesson_id = params[:lesson_id].to_i || session[:lesson_id]
    my_questions = (Question.where(:is_public => true) + Question.where(:author => current_user.id)).uniq.sort
    @exist_question = my_questions.map{|q| [q.title, q.id]}.to_h
  end

  def create
    lesson_id = params[:lesson_id] || session[:lesson_id]
    question_id = params[:question_id] || session[:question_id]

    ##ファイルサイズは10MB以上の場合　#ajax
    # 保存失敗時のajax用の変数
    params[:lesson_id] = lesson_id
    @lesson = Lesson.find_by(:id => lesson_id)
    @questions = @lesson.lesson_questions
    @is_teacher = @lesson.user_lessons.find_by(:user_id => current_user.id, :lesson_id => lesson_id).is_teacher

    if flash[:is_refer]
      lesson_question = LessonQuestion.new(:question_id => question_id,
                                           :lesson_id => lesson_id,
                                           :start_time => params[:start_time],
                                           :end_time => params[:end_time])
      if lesson_question.save
        flash.notice = '問題を登録しました'
      else
        flash.notice = '問題を登録に失敗しました'
      end
      return
    end

    # アップロードされたテストデータを取得
    # TestDatumモデルにはファイル名を入力
    test_data = {}
    params[:question][:test_data_attributes].each.with_index(1) do |(key, val), i|
      files = {}

      # データが無い項目は無視
      if val[:input].nil?
        next
      end

      # ファイルの取得
      files[:input] = val[:input]
      files[:output] = val[:output]
      if files[:input].size > 10.megabyte || files[:output].size > 10.megabyte
        flash[:alert] = 'ファイルサイズは10MBまでにしてください。'
        return
      end

      # ファイルの入っていた項目にファイル名などを保存
      val[:input] = val[:input].original_filename
      val[:output] = val[:output].original_filename
      val[:input_storename] = "input#{i}"
      val[:output_storename] = "output#{i}"
      test_data["#{i}"] = files
    end
    params[:question][:version] = 1

    # パブリック化の有無
    if params[:question][:is_public] != "false"
      params[:question][:lesson_questions_attributes]['100101010'] = {'lesson_id' => "1"}
    end

    @question = Question.new(question_params)
    @question.author = current_user.id

    if @question.save
      flash.notice='問題を登録しました'

      # テストデータのディレクトリを作成
      uploads_test_data_path = UPLOADS_QUESTIONS_PATH.join(@question.id.to_s)
      FileUtils.mkdir_p(uploads_test_data_path) unless FileTest.exist?(uploads_test_data_path)

      # テストデータの保存
      test_data.each do |key, val|
        File.open("#{uploads_test_data_path}/input#{key}", "wb") do |f|
          f.write(val[:input].read)
        end
        File.open("#{uploads_test_data_path}/output#{key}", "wb") do |f|
          f.write(val[:output].read)
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
  # @param [Fixnum] lesson_question_id
  def show
    session[:lesson_question_id] = params[:lesson_question_id] .present? ? params[:lesson_question_id] : session[:lesson_question_id]
    session[:question_id] = params[:question_id]
    lesson_question_id = session[:lesson_question_id]
    question_id = session[:question_id]
    lesson_id = session[:lesson_id] || 1
    unless check_lesson_question(:lesson_id => lesson_id,
                                 :question_id => question_id,
                                 :lesson_question_id => lesson_question_id)
      return
    end

    @question = Question.find_by(:id => params[:question_id])
    @lesson = Lesson.find_by(:id => lesson_id)
    @latest_answer = Answer.latest_answer(:student_id => current_user.id,
                                          :question_id => question_id,
                                          :lesson_id => lesson_id,
                                          :lesson_question_id => lesson_question_id) || nil
    @is_teacher = UserLesson.find_by(:user_id => current_user.id, :lesson_id => lesson_id).is_teacher
    if @is_teacher
      @multi_check_enable = 0
      @students = User.where(:id => @lesson.user_lessons.where(:is_teacher => false).pluck(:user_id))
      @students.each do |s|
        answer = Answer.latest_answer(:student_id => s.id,
                                      :question_id => @question.id,
                                      :lesson_id => @lesson.id,
                                      :lesson_question_id => lesson_question_id)
        if answer.present?
          checked_result = InternetCheckResult.where(:answer_id =>answer.id)
          if checked_result.count == 0
            @multi_check_enable = 1
          end
        end
      end
    else
      @languages = LANGUAGES.map { |val| [val, val.downcase] }.to_h
    end
  end

  def edit
    @lesson_id = params[:lesson_id]
    @question_id = params[:question_id]
    @question = Question.find_by(:id =>@question_id)
    @is_public = @question.is_public
  end

  def update
    @lesson_id = params[:lesson_id] || session[:lesson_id]
    @question_id = params[:question_id] || session[:question_id]
    @question = Question.find_by(:id =>@question_id)

    ##ajax
    params[:lesson_id] = @lesson_id
    @lesson = Lesson.find_by(:id => @lesson_id)
    @questions = @lesson.lesson_questions
    @is_teacher = Lesson.find_by(:id => @lesson_id).user_lessons.find_by(:user_id => current_user.id, :lesson_id => @lesson_id).is_teacher

    version_up = false
    test_data = {}
    start_num = @question.test_data.size

    if @question.run_time_limit != params[:question][:run_time_limit].to_i || @question.memory_usage_limit != params[:question][:memory_usage_limit].to_i
      version_up = true
    end

    params[:question][:samples_attributes].each do |key, val|
      if val[:_destroy] != 'false'
        val[:is_deleted] = true
      end
    end

    params[:question][:question_keywords_attributes].each do |key, val|
      if val[:_destroy] != 'false'
        val[:is_deleted] = true
      end
    end

    params[:question][:test_data_attributes].each.with_index(1) do |(key, val), i|
      if val[:input].nil? || val[:output].nil?
        next
      end

      files = {}
      if val["id"].to_s == ""
        version_up = true
        files[:input] = val[:input]
        files[:output] = val[:output]
        if files[:input].size > 10.megabyte || files[:output].size > 10.megabyte
          flash[:alert] = 'ファイルサイズは10MBまでにしてください。'
          return
        end
        start_num = start_num + 1

        val[:input] = val[:input].original_filename
        val[:output] = val[:output].original_filename
        val[:input_storename] = "input#{start_num}"
        val[:output_storename] = "output#{start_num}"
        test_data["#{start_num}"] = files
      end

      if val[:_destroy] != 'false'
        version_up = true
        val[:is_deleted] = true
      end
   end

    if version_up
      params[:question][:version] = params[:question][:version].to_i + 1
    end

    # パブリック化の有無
    if (params[:question][:is_public] != "false") && (@question.is_public != true)
      params[:question][:lesson_questions_attributes]['100101010'] = {'lesson_id' => "1"}
    end

    if @question.update(params[:question])

      # テストデータのディレクトリを作成
      uploads_test_data_path = UPLOADS_QUESTIONS_PATH.join(@question.id.to_s)
      FileUtils.mkdir_p(uploads_test_data_path) unless FileTest.exist?(uploads_test_data_path)

      # テストデータの保存
      test_data.each do |key, val|
        File.open("#{uploads_test_data_path}/input#{key}", "wb") do |f|
          f.write(val[:input].read)
        end
        File.open("#{uploads_test_data_path}/output#{key}", "wb") do |f|
          f.write(val[:output].read)
        end
      end
      flash.notice = '問題を更新しました'
    else
      flash.notice='問題の更新に失敗しました'
    end

  end

  def get_exist_question
    question_id = params[:question_id]
    session[:question_id] = question_id
    @question = Question.find_by(:id => question_id)
    my_questions = (Question.where(:is_public => true) + Question.where(:author => current_user.id)).uniq.sort
    @exist_question = my_questions.map{|q| [q.title, q.id]}.to_h
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
                                     :version,
                                     :author,
                                     :is_public,
                                     samples_attributes: [:question_id, :input, :output, :is_deleted],
                                     test_data_attributes: [:question_id, :input, :output, :input_storename, :output_storename, :is_deleted],
                                     question_keywords_attributes: [:question_id, :keyword, :is_deleted],
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
    @questions = Question.find_by(:id => question_id)
  end

  # 該当する授業が存在するかどうか
  # @param [Fixnum] lesson_id
  # @param [Fixnum] question_id
  def check_lesson
    id = params[:lesson_id] || 1
    return unless access_lesson_check(:user_id => current_user.id, :lesson_id => id)
  end

  # 該当する授業と問題の関連が存在するかどうか
  # @param [Fixnum] lesson_id
  # @param [Fixnum] question_id
  # @param [Fixnum] lesson_question_id
  # @return [Boolean]
  def check_lesson_question(lesson_id:, question_id:, lesson_question_id:)
    return LessonQuestion.find_by(:lesson_id => lesson_id,
                                  :question_id => question_id,
                                  :id => lesson_question_id).present?
  end
end
