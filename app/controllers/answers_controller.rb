# -*- coding: utf-8 -*-
class AnswersController < ApplicationController

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


end
