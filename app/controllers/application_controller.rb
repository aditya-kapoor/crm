class ApplicationController < ActionController::Base
  protect_from_forgery

  # def current_user
  #   Admin.find_by_id(session[:user_id])
  # end

  # helper_method :current_user

  private

  def after_sign_out_path_for(resource_or_scope)
    new_admin_session_path
  end
end
