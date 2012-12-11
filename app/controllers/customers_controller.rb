class CustomersController < ApplicationController

  before_filter :check_for_empty_params, :only => [:export_to_csv]
  before_filter :check_for_session

  @@rpp = 10
  def index
    @customers = Customer.includes([:address, :emails, :phone_numbers]).scoped.page(params[:page]).per(@@rpp)
  end

  def create
    @customer = Customer.new(params[:customer])
    if @customer.save
      redirect_to root_path, :notice => "Successfully Created New Customer"
    else
      render "new"
    end
  end

  def edit
    @customer = Customer.find_by_id(params[:id])
  end

  def update
    @customer = Customer.find_by_id(params[:id])
    if @customer.update_attributes(params[:customer])
      redirect_to customers_path, :notice => "Successfully Updated"
    else
      render "edit"
    end
  end

  def new
    @customer = Customer.new
    @customer.build_address
    2.times { @customer.emails.build }
    2.times { @customer.phone_numbers.build }
    @customer.build_special_note
  end

  def show
    @customer = Customer.includes([:address, :emails, :phone_numbers]).find_by_id(params[:id])
  end

  def destroy
    @customer = Customer.find_by_id(params[:id])
    @customer.destroy
    redirect_to root_path, :notice => "Successfully Destroyed Customer"
  end

  def export_to_csv
    @customers = Customer.find_all_by_id(params[:customer_ids])
    csv_string = CSV.generate do |csv|
      csv << ["Name", "Email", "Phone Number"]
      @customers.each do |customer|
        csv << [customer.name, customer.emails.collect(&:address).join(", "), customer.phone_numbers.collect(&:phone).join(", ")]
      end
    end
    send_data csv_string, :type => 'text/csv; charset=iso-8859-1;header=present', :disposition => "attachment", :filename => "customers.csv"
  end

  def get_results
    @customers = Customer.search "#{params[:search_string]}*"
    respond_to do |format|
      format.json { render :json => @customers }
    end
  end


  private 
  def check_for_empty_params
    if params[:customer_ids].blank?
      flash[:error] = "No ids sent"
      redirect_to request.referrer
    end
  end

  def check_for_session
    unless session[:user_id].present?
      flash[:error] = "No Logged in user"
      redirect_to root_path
    end
  end
end
