# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # ユーザ権限がない場合などで例外が出た場合，例外表示のかわりにrootにリダイレクト
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to "/", :alert => exception.message
  end

  def access_lesson_check(user_id: ,lesson_id:)
    lesson = Lesson.find_by(:id => lesson_id)
    if(lesson_id== "1" || lesson.nil?)
      redirect_to root_path, :alert => "該当する授業が存在しません"
      return false
    elsif lesson.user_lessons.where(:lesson_id=>lesson_id,:user_id=>user_id).empty?
      redirect_to root_path, :alert => "該当する授業に参加していません"
      return false
    end
    return true
  end

end
