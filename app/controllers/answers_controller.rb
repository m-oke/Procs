# -*- coding: utf-8 -*-
class AnswersController < ApplicationController

  # post '/answers'
  # @param [Binary] upload_file アップロードファイル
  # @param [language] language 選択言語
  # @param [Fixnum] lesson_id
  # @param [Fixnum] id Questionのid
  def index
    @diff = show_diff("uploads/7/2/2/version3.py", "uploads/7/2/2/version4.py")

  end

  def create
    file = params[:upload_file]
    unless file.nil?
      extention = Answer::EXT[params[:language]]
      name = file.original_filename

      if !(extention == File.extname(name).downcase)
        flash[:alert] = '使用言語とファイル拡張子が一致しません。'
      elsif file.size > 10.megabyte
        flash[:alert] = 'ファイルサイズは10MBまでにしてください。'
      else
        path = Rails.root.join('uploads', current_user.id.to_s, params[:lesson_id], params[:id]).to_s
        FileUtils.mkdir_p(path) unless FileTest.exist?(path)

        old_file = Answer.where(:lesson_id => params[:lesson_id],
                               :student_id => current_user.id,
                               :question_id => params[:id]).last
        /\d+/ =~ old_file.file_name unless old_file.nil?
        version = $&.to_i
        next_version = (version + 1).to_s
        next_name = "version" + next_version + extention

        File.open(path + "/" + next_name, 'wb') do |f|
          f.write(file.read)
        end
        answer = Answer.new(:language => params[:language],
                            :question_id => params[:id],
                            :lesson_id => params[:lesson_id],
                            :file_name => next_name,
                            :result => 1,
                            :student_id => current_user.id)
        answer.save
        flash[:notice] = '回答を投稿しました。'
      end
    else
      flash[:alert] = 'ファイルが選択されていません。'
    end
    redirect_to :controller => 'questions', :action => 'show', :lesson_id => params[:lesson_id], :id => params[:id]
  end

  private
  def show_diff(original_file, new_file)
    output = `diff -t --new-line-format='+%L' --old-line-format='-%L' --unchanged-line-format=' %L' #{original_file} #{new_file} > ./app/assets/diff.txt`
    diff = File.open('./app/assets/diff.txt', 'r:utf-8')
    return diff
  end

end
