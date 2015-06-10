class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout :set_layout

  private
  def set_layout
    if params[:controller].match(%r{\A(teacher|student)/})
      Regexp.last_match[1]
    else
      'application'
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to "/", :alert => exception.message
  end


end
