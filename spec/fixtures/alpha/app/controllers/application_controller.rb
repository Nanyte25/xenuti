class ApplicationController < ActionController::Base
  protect_from_forgery

  def show
    params[:user_supplied].to_sym
  end
end
