# -*- coding: utf-8 -*-
class AnswersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @student_id = params[:student_id] || current_user.id
    @lesson_id = params[:lesson_id] || session[:lesson_id] || 1
    @question_id = params[:question_id] || session[:question_id]
    lesson_question_id = params[:lesson_question_id] || session[:lesson_question_id]
    @question = Question.find_by(:id => @question_id)
    if Lesson.find_by(:id => @lesson_id).nil? || Question.find_by(:id => @question_id).nil? || User.find_by(:id => @student_id).nil?
      redirect_to root_path, :alert => '該当する解答は存在しません' and return
    end
    unless params[:student_id].nil?
      @is_teacher = Lesson.find_by(:id => @lesson_id).user_lessons.find_by(:user_id => current_user.id, :lesson_id => @lesson_id)

      # 該当授業の教師かどうかを取得
      if @is_teacher.nil?
        redirect_to root_path, :alert => '該当する授業に参加していません' and return
      end
      @is_teacher = @is_teacher.is_teacher
      unless @is_teacher
        redirect_to root_path, :alert => '該当する解答は存在しません' and return
      end
    end

    @answer_all_version= Answer.where(:question_id => @question_id,
                                      :lesson_id=> @lesson_id,
                                      :lesson_question_id => lesson_question_id,
                                      :student_id=> @student_id )

    @dead_date_question = LessonQuestion.find_by(:id => lesson_question_id)

    @raw_display_file  = @answer_all_version.last.file_name

    @path_directory = UPLOADS_ANSWERS_PATH.join(@student_id.to_s, lesson_question_id.to_s).to_s + "/"
    flash[:directory]= @path_directory

    @new_raw_path = @path_directory + @raw_display_file
  end

  # post '/answers'
  # @param [Binary] upload_file アップロードファイル
  # @param [language] language 選択言語
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Questionのid
  def create
    file = params[:upload_file]
    lesson_question_id = session[:lesson_question_id]
    question_id = session[:question_id]
    lesson_id = session[:lesson_id].present? ? session[:lesson_id] : 1

    # ajax用の変数
    @lesson = Lesson.find_by(:id => lesson_id)
    @question = Question.find_by(:id => question_id)
    @is_teacher = Lesson.find_by(:id => lesson_id).user_lessons.find_by(:user_id => current_user.id, :lesson_id =>lesson_id).is_teacher
    @languages = LANGUAGES.map { |val| [val, val.downcase] }.to_h

    # ファイルが選択されている場合
    unless file.nil?
      extention = EXT[params[:language]]
      name = file.original_filename

      # ファイルのチェック
      if !(extention == File.extname(name).downcase)
        flash[:alert] = '使用言語とファイル拡張子が一致しません。'
      elsif file.size > 10.megabyte
        flash[:alert] = 'ファイルサイズは10MBまでにしてください。'
      else

        # 保存ディレクトリの作成
        uploads_answers_path = UPLOADS_ANSWERS_PATH.join(current_user.id.to_s, lesson_question_id.to_s)
        FileUtils.mkdir_p(uploads_answers_path) unless FileTest.exist?(uploads_answers_path)

        # 最後の解答のファイル名の取得
        old_file = Answer.where(:lesson_id => lesson_id,
                                :student_id => current_user.id,
                                :lesson_question_id => lesson_question_id,
                                :question_id => question_id).last
        /\d+/ =~ old_file.file_name unless old_file.nil?
        version = $&.to_i
        next_version = (version + 1).to_s
        next_name = "version#{next_version}#{extention}"

        # ファイルの保存
        File.open("#{uploads_answers_path}/#{next_name}", 'wb') do |f|
          f.write(file.read)
        end

        # Answerモデルの保存
        answer = Answer.new(:language => params[:language],
                            :question_id => question_id,
                            :lesson_id => lesson_id,
                            :lesson_question_id => lesson_question_id,
                            :file_name => next_name,
                            :result => "P",
                            :student_id => current_user.id,
                            :run_time => 0,
                            :memory_usage => 0,
                            :question_version =>@question.version)
        unless answer.save
          flash[:notice] = "解答の保存に失敗しました．" and return
        end
        @latest_answer = answer
        flash[:notice] = '解答を投稿しました。'

        # 評価スクリプトをメッセージキューに入れる
        case params[:language]
        when 'python'
          EvaluatePythonJob.perform_later(:user_id => current_user.id,
                                          :lesson_id => lesson_id,
                                          :question_id => question_id,
                                          :lesson_question_id => lesson_question_id)
        when 'c'
          EvaluateCJob.perform_later(:user_id => current_user.id,
                                     :lesson_id => lesson_id,
                                     :question_id => question_id,
                                     :lesson_question_id => lesson_question_id)
        end
      end

      # ファイルが選択されていなかった場合
    else
      @latest_answer = Answer.latest_answer(:student_id => current_user.id,
                                            :question_id => question_id,
                                            :lesson_id => lesson_id,
                                            :lesson_question_id => lesson_question_id) || nil
      flash[:alert] = 'ファイルが選択されていません。'
    end

    # パブリック授業の場合
    if @lesson.id == 1
      redirect_to :controller => 'questions', :action => 'show',  :question_id => question_id
    end
  end

  def select_version
    @select_item = params[:selected_file]
    @select_path = flash[:directory]
    @new_raw_path = @select_path.to_s + @select_item
    flash[:directory] = flash[:directory]
  end

  def diff_select
    flash[:directory] = flash[:directory]
    @select_diff_file = params[:diff_selected_file]
    @select_raw_file = params[:raw_selected_file]

    @select_raw_name = flash[:directory].to_s + @select_raw_file
    if @select_diff_file == "なし"
      return
    end

    select_diff_name = flash[:directory].to_s + @select_diff_file
    @diff = show_diff(@select_raw_name, select_diff_name)
  end


  private
  def show_diff(original_file, new_file)
    file = "./tmp/" + Digest::MD5.hexdigest(DateTime.now.to_s + rand.to_s) + ".txt"
    output = `diff -t --new-line-format='+%L' --old-line-format='-%L' --unchanged-line-format=' %L' #{original_file} #{new_file} > #{file}`
    diff = File.open("#{file}", 'r:utf-8')
    `rm #{file}`
    return diff
  end
end
