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

    ##ファイルサイズは10MB以上の場合　#ajax
    # 保存失敗時のajax用の変数
    params[:lesson_id] = @lesson_id
    @lesson = Lesson.find_by(:id => @lesson_id)
    @questions = @lesson.question
    @is_teacher = Lesson.find_by(:id => @lesson_id).user_lessons.find_by(:user_id => current_user.id, :lesson_id => @lesson_id).is_teacher
    # アップロードされたテストデータを取得
    # TestDatumモデルにはファイル名を入力
    test_data = {}
    params['question']['test_data_attributes'].each.with_index(1) do |(key, val), i|
      files = {}
      if val['input'].nil?
        next
      end
      files['input'] = val['input']
      files['output'] = val['output']
      if files['input'].size > 10.megabyte || files['output'].size > 10.megabyte
        flash[:alert] = 'ファイルサイズは10MBまでにしてください。'
        return
      end
      val['input'] = val['input'].original_filename
      val['output'] = val['output'].original_filename
      val['input_storename'] = "input#{i}"
      val['output_storename'] = "output#{i}"
      test_data["#{i}"] = files
    end

    @question = Question.new(question_params)
    if @question.save
      flash.notice='問題を登録しました'

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

  def edit
    @lesson_id = params[:lesson_id]
    @question_id = params[:question_id]
    @question = Question.find_by(:id =>@question_id)
  end

  def update
    @lesson_id = params[:lesson_id]
    @question_id = params[:question_id]
    @question = Question.find_by(:id =>@question_id)

    ##ajax
    params[:lesson_id] = @lesson_id
    @lesson = Lesson.find_by(:id => @lesson_id)
    @questions = @lesson.question
    @is_teacher = Lesson.find_by(:id => @lesson_id).user_lessons.find_by(:user_id => current_user.id, :lesson_id => @lesson_id).is_teacher

    original_input_output_file = Hash.new  # for original
    # now_input_output_file = {} # for now all file  (difference from new_input_output_file)
    # new_input_output_file = {}  #for add file
    delete_input_output_file = Hash.new  #for delete file

    @question.test_data.each do |item|
      original_input_output_file[item['input_storename']] = item['input']
      original_input_output_file[item['output_storename']] = item['output']
    end
    start_num = 1
    original_input_output_file.each_key do |key_name|
      if key_name.include?("input")
        num = key_name[5..key_name.size-1].to_i
        if num > start_num
          start_num = num
        end
      end
    end
    test_data = {}

    params['question']['test_data_attributes'].each.with_index(1) do |(key, val), i|
binding.pry
      if val['input'].nil? || val['output'].nil?
        next
      end
      files = {}
      if val['input'].is_a?(Hash) || val['output'].is_a?(Hash)
        val_input = val['input'].original_filename
        val_output = val['output'].original_filename
      else
        val_input = val['input']
        val_output = val['output']
      end

      if original_input_output_file.has_value?(val_input) && original_input_output_file.has_value?(val_output)

        if val_input == val_output
          same_key =[]
          original_input_output_file.each_key do |key|
            if original_input_output_file[key] == val_input
              same_key.push(key)
            end
          end

        else
          original_input_output_file.each do |k,v|
            if v == val_input
              val['input_storename'] = k
            end
            if v == val_output
              val['output_storename'] = k
            end
          end
        end
      else
        files['input'] = val['input']
        files['output'] = val['output']
        if files['input'].size > 10.megabyte || files['output'].size > 10.megabyte
          flash[:alert] = 'ファイルサイズは10MBまでにしてください。'
          return
        end
        start_num = start_num + 1

        val['input'] = val['input'].original_filename
        val['output'] = val['output'].original_filename
        val['input_storename'] = "input#{start_num}"
        val['output_storename'] = "output#{start_num}"
        # new_input_output_file.store(val['input_storename'], val['input'])
        # new_input_output_file.store(val['output_storename'], val['output'])
        test_data["#{start_num}"] = files
      end
      if val['_destroy'] != 'false'

        delete_input_output_file[val['input_storename']] = val['input']
        delete_input_output_file[val['output_storename']] = val['output']
      end

   end
    # @question.assign_attributes(params['question'])
    if @question.update(params['question'])

      # テストデータのディレクトリを作成
      uploads_test_data_path = UPLOADS_QUESTIONS_PATH.join(@question.id.to_s)
      FileUtils.mkdir_p(uploads_test_data_path) unless FileTest.exist?(uploads_test_data_path)
      # delete no use file
      delete_input_output_file.each do |key,val|
        file_name = "#{uploads_test_data_path}/" + key
        if File.exist?(file_name)
          File.delete(file_name)
        end
      end
      # テストデータの保存
      test_data.each do |key, val|
        File.open("#{uploads_test_data_path}/input#{key}", "wb") do |f|
          f.write(val['input'].read)
        end
        File.open("#{uploads_test_data_path}/output#{key}", "wb") do |f|
          f.write(val['output'].read)
        end
      end
      flash.notice = '問題を更新しました'
    else
      flash.notice='問題の更新に失敗しました'
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
      test_data_attributes: [:question_id, :input, :output, :input_storename, :output_storename, :_destroy],
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
