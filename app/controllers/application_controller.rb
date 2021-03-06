# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  I18n.backend.reload!
  # ユーザ権限がない場合などで例外が出た場合，例外表示のかわりにrootにリダイレクト
  # rescue_from CanCan::AccessDenied do |exception|
  #   session[:error] = "test"
  #   redirect_to "/", :alert => (current_user.nil? ? "" : exception.message)
  # end

  # ユーザが該当する授業に参加しているかどうかをチェック
  # 参加していなかったらrootにリダイレクト
  # @param [Fixnum] user_id
  # @param [Fixnum] lesson_id
  # @return [Boolean]
  def access_lesson_check(user_id:, lesson_id:)
    lesson = Lesson.find_by(:id => lesson_id)
    private_lesson = UserLesson.where(:lesson_id =>lesson.id, :is_deleted => 1, :user_id=>user_id, :is_teacher => false)
    if (lesson_id == "1" || lesson.nil? ||private_lesson.present?)
      redirect_to root_path, :alert => "該当する授業が存在しません"
      return false
    elsif lesson.user_lessons.where(:lesson_id => lesson_id, :user_id => user_id).empty?
      redirect_to root_path, :alert => "該当する授業に参加していません"
      return false
    end
    return true
  end

  # 該当する問題が登録されているかどうかをチェック
  # 登録されていなければlesson_pathにリダイレクト
  # @param [Fixnum] user_id
  # @param [Fixnum] lesson_id
  # @param [Fixnum] question_id
  # @return [Boolean]
  def access_question_check(user_id:, lesson_id:, question_id:)
    if access_lesson_check(:user_id => user_id, :lesson_id => lesson_id)
      question = Question.find_by(:id => question_id)
      if question.nil?
        redirect_to lesson_path(:id => lesson_id), :alert => "該当する問題が存在しません"
        return false
      elsif question.lesson_questions.where(:lesson_id => lesson_id).empty?
        redirect_to lesson_path(:id => lesson_id), :alert => "該当する問題はこの授業には登録されていません"
        return false
      end
      return true
    else
      return false
    end
  end
end
