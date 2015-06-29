# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # ユーザ権限がない場合などで例外が出た場合，例外表示のかわりにrootにリダイレクト
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to "/", :alert => exception.message
  end


end
