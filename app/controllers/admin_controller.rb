class AdminController < ApplicationController

  def index
    @admins = Admin.all
  end

  def show
    @admin = Admin.find_by_id(params[:id])
  end

  def new
    @admin = Admin.new
  end

  def add_new_admin
    @admin = Admin.new
  end

  def save_new_admin
    @admin = Admin.new(params[:admin])
    if @admin.save
      flash[:notice] = "Successfully created the new admin"
      redirect_to @admin
    else
      render "add_new_admin"
    end
  end
end
