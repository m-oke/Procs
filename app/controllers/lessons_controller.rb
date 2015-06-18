# -*- coding: utf-8 -*-
class LessonsController < ApplicationController
  def index
  end

  def join_page
    render :join
  end

  def join
    lesson = Lesson.find_by_lesson_code(params[:lesson_code])
    if lesson.nil?
      flash.now[:notice] = "該当する授業が存在しません"
      render :join  and return
    end

    @user_lesson = UserLesson.new(
                                  :user_id => current_user.id,
                                  :lesson_id => lesson.id,
                                  :is_teacher => current_user.has_role?(:teacher))

    if !UserLesson.exists?(:user_id => current_user.id, :lesson_id => lesson.id, :is_teacher => current_user.has_role?(:teacher)) &&
        @user_lesson.save
      flash[:notice] = "「#{lesson.name}」に参加しました。"
      redirect_to :action => 'index'
    else
      flash.now[:alert] = "あなたは既にこの授業に参加しています。"
      render :join and return
    end

  end
end
