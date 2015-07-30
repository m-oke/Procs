# -*- coding: utf-8 -*-
class AnswersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @student_id = params[:user_id]
    @lesson_id = params[:lesson_id]
    @question_id = params[:question_id]
    if Lesson.find_by(:id => @lesson_id).nil? || Question.find_by(:id => @question_id).nil? || User.find_by(:id => @student_id).nil?
      redirect_to root_path, :alert => 'パスが間違っています' and return
    end
    @question_all_version= Answer.where(:question_id => @question_id,
                                        :lesson_id=> @lesson_id,
                                        :student_id=> @student_id )
    @dead_date_question = LessonQuestion.find_by(lesson_id: @lesson_id  ,
                                                 question_id: @question_id )

    @raw_display_file  = Answer.where(:question_id => @question_id,
                               :lesson_id=> @lesson_id,
                               :student_id=> @student_id ).last.file_name

    @path_directory ='./uploads/'+ @student_id.to_s +  '/' + @lesson_id.to_s + '/' + @question_id.to_s + '/'
    flash[:directory]= @path_directory

    @new_raw_path = @path_directory + @raw_display_file

    # 該当授業の教師かどうかを取得
    if Lesson.find_by(:id => @lesson_id).user_lessons.find_by(:user_id => current_user.id, :lesson_id => @lesson_id).nil?
      flash[:notice] = "該当する授業に参加していません"
      redirect_to :controller => 'lessons', :action => 'index'
    else
      @is_teacher = Lesson.find_by(:id => @lesson_id).user_lessons.find_by(:user_id => current_user.id, :lesson_id => @lesson_id).is_teacher
    end
  end

  # post '/answers'
  # @param [Binary] upload_file アップロードファイル
  # @param [language] language 選択言語
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Questionのid
  def create
    file = params[:upload_file]
    lesson_id = params[:lesson_id].present? ? params[:lesson_id] : "1"
    question_id = params[:id]
    unless file.nil?
      extention = EXT[params[:language]]
      name = file.original_filename

      if !(extention == File.extname(name).downcase)
        flash[:alert] = '使用言語とファイル拡張子が一致しません。'
      elsif file.size > 10.megabyte
        flash[:alert] = 'ファイルサイズは10MBまでにしてください。'
      else
        path = Rails.root.join('uploads', current_user.id.to_s, lesson_id, question_id).to_s
        FileUtils.mkdir_p(path) unless FileTest.exist?(path)

        old_file = Answer.where(:lesson_id => lesson_id,
                               :student_id => current_user.id,
                               :question_id => question_id).last
        /\d+/ =~ old_file.file_name unless old_file.nil?
        version = $&.to_i
        next_version = (version + 1).to_s
        next_name = "version" + next_version + extention

        File.open(path + "/" + next_name, 'wb') do |f|
          f.write(file.read)
        end
        answer = Answer.new(:language => params[:language],
                            :question_id => question_id,
                            :lesson_id => lesson_id,
                            :file_name => next_name,
                            :result => "P",
                            :student_id => current_user.id,
                            :run_time => 0,
                            :memory_usage => 0)
        answer.save
        flash[:notice] = '回答を投稿しました。'
        case params[:language]
        when 'python'
          EvaluatePythonJob.perform_later(:user_id => current_user.id,
                                          :lesson_id => lesson_id,
                                          :question_id => question_id)
        when 'c'
          EvaluateCJob.perform_later(:user_id => current_user.id,
                                          :lesson_id => lesson_id,
                                          :question_id => question_id)
        end
      end
    else
      flash[:alert] = 'ファイルが選択されていません。'
    end
    if lesson_id == "1"
      redirect_to :controller => 'questions', :action => 'show', :id => question_id and return
    end
    redirect_to :controller => 'questions', :action => 'show', :lesson_id => lesson_id, :id => question_id
  end

  def select_version
    @select_item = params[:selected_file]
    @select_path = flash[:directory]
    @new_raw_path = @select_path.to_s + @select_item
    flash[:directory] = flash[:directory]
  end

  def diff_select

    @select_diff_file = params[:diff_selected_file]
    @select_raw_file = params[:raw_selected_file]

    @select_diff_name = flash[:directory].to_s + @select_diff_file
    @select_raw_name = flash[:directory].to_s + @select_raw_file
    @diff = show_diff(@select_raw_name, @select_diff_name)
    flash[:directory] = flash[:directory]
  end


  private
  def show_diff(original_file, new_file)
    output = `diff -t --new-line-format='+%L' --old-line-format='-%L' --unchanged-line-format=' %L' #{original_file} #{new_file} > ./tmp/diff.txt`
    diff = File.open('./tmp/diff.txt', 'r:utf-8')
    return diff
  end
end
