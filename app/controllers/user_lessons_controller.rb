# -*- coding: utf-8 -*-
class UserLessonsController < ApplicationController
  # get '/lessons/join'
  # 授業への参加ページ
  def new
  end

  #   post '/lessons/join'
  #   授業への参加
  #   ログインしているユーザが授業コードに該当する授業に参加する
  # @param [String] :lesson_code 授業コード
  def create
    lesson = Lesson.find_by(:lesson_code => params[:lesson_code])
    if lesson.nil?
      flash.now[:notice] = "該当する授業が存在しません"
      render :new  and return
    end

    @user_lesson = UserLesson.new(:user_id => current_user.id,
                                  :lesson_id => lesson.id,
                                  :is_teacher => false)

    if !UserLesson.exists?(:user_id => current_user.id, :lesson_id => lesson.id, :is_teacher => false) &&
        @user_lesson.save
      flash[:notice] = "「#{lesson.name}」に参加しました。"
      redirect_to :controller => 'lessons', :action => 'show', :id => lesson.id
    else
      flash.now[:alert] = "あなたは既にこの授業に参加しています。"
      render :new and return
    end

  end
end
