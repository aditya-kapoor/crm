class SessionsController < ApplicationController

  def create
    @admin = Admin.find_by_username(params[:username])
    if @admin && @admin.authenticate(params[:password])
      session[:user_id] = @admin.id
      # flash[:notice] = "Correct username/password combination"
      redirect_to customers_path
    else
      flash[:error] = "Wrong username/password combination"
      redirect_to request.referrer
    end
  end

  def logout
    reset_session
    flash[:notice] = "Successfully Logged Out"
    redirect_to root_path
  end
end
