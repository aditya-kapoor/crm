class AdminController < ApplicationController

  def index
  end

  def show
    @admin = Admin.find_by_id(params[:id])
  end
end
