class CustomersController < ApplicationController

  before_filter :check_for_empty_params, :only => [:export_to_csv]
  # before_filter :check_for_admin
  before_filter :authenticate_admin!
  before_filter :check_csv_file, :only => [:import_csv]
  before_filter :check_for_empty_customer, :only => [:merge_and_save_contacts]
  before_filter :check_for_customer, :only => [:merge_contacts]

  @@rpp = 10
  def index
    @customers = Customer.includes([:address, :emails, :phone_numbers, :special_note]).scoped.page(params[:page]).per(@@rpp)
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
    @customer = Customer.includes([:address, :emails, :phone_numbers, :special_note]).find_by_id(params[:id])
  end

  def destroy
    @customer = Customer.find_by_id(params[:id])
    @customer.destroy
    redirect_to root_path, :notice => "Successfully Destroyed Customer"
  end

  def export_to_csv
    column_names = params[:columns] || ["Name", "Emails", "Phone Numbers", "Address", "Special Note"]
    @customers = Customer.find_all_by_id(params[:customer_ids])
    csv_string = CSV.generate do |csv|
      csv << column_names.map { |col| col.titleize }
      @customers.each do |customer|
        unless params[:columns].present?
          csv << [customer.name, customer.emails.collect(&:address).join(", "), customer.phone_numbers.collect(&:phone).join(", "), customer.address.complete_address, customer.special_note.description]
        else
          temporary_array = generate_csv_array(column_names, customer)
          csv << temporary_array.flatten
        end
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

  def start_merge_contacts
    @customers = Customer.all
  end

  def merge_contacts
    @customer1 = Customer.find_by_id(params[:customer1])
    @customer2 = Customer.find_by_id(params[:customer2])
  end

  def merge_and_save_contacts
    @customer = Customer.find_by_id(params[:selected_record])
    if params[:customer].present?
      if params[:customer].keys.include?("name")
        @customer.update_attributes(params[:customer][:name])
      end
      if params[:customer].keys.include?("address")
        address_attributes = @customer.address.attributes.merge!(params[:customer][:address]).select { |key| Address.accessible_attributes.reject { |attribute| attribute.blank? }.include?(key) }
        @customer.update_attribute("address_attributes", address_attributes)
      end
      if params[:customer].keys.include?("emails")
        save_changes("emails", params[:customer], @customer)
      end
      if params[:customer].keys.include?("phone_numbers")
        save_changes("phone_numbers", params[:customer], @customer)
      end
    end
    @customer.save
    Customer.find_by_id(id_to_be_deleted).destroy
    flash[:notice] = "Successfully Merged and deleted non chosen contact"
    redirect_to start_merge_contacts_customers_path
  end

  def upload_csv
  end

  def import_csv
    params[:fields].uniq!
    params[:fields].reject! { |x| x.blank? }
    file = params[:file]
    begin
      @hash = Customer.import(file, params[:fields])
      # flash[:notice] = "CSV Imported Successfully now edit the details so that we can save it in the database"
    rescue => e
      flash[:error] = "There was some error with your file or field selection"
      redirect_to upload_csv_customers_path
    end
  end

  def save_csv_contents
    params["customers"].each do |key, customer|
      @customer = Customer.new(customer["name"])
      @customer.build_address(customer["address"])
      @customer.build_special_note(customer["special_note"])
      if customer["emails"].present?
        build_credentials("emails", customer, @customer)
      end
      if customer["phone_numbers"].present?
        build_credentials("phone_numbers", customer, @customer)
      end
      @customer.save
    end
    flash[:notice] = "CSV has been Successfully imported and stored"
    redirect_to root_path
  end

  private 
  def check_for_empty_params
    if params[:customer_ids].blank?
      flash[:error] = "No ids sent"
      redirect_to request.referrer
    end
  end

  def check_for_admin
    unless session[:user_id].present?
      flash[:error] = "No Logged in user"
      redirect_to root_path
    end
  end

  def check_csv_file
    unless params[:file].content_type == "text/csv"
      flash[:error] = "There Was some problem with your file"
      redirect_to upload_csv_customers_path
    end
  end

  def check_for_empty_customer
    unless params[:customer].present?
      # this means there are no selections to be made therefore we must destroy the other 
      # customer object
      @customer = Customer.find_by_id(id_to_be_deleted)
      @customer.destroy
      flash[:notice] = "Successfully Removed Duplicate Contact"
      redirect_to start_merge_contacts_customers_path
    end
  end

  def id_to_be_deleted
    (params[:selected_record] == params[:customer1][:id] ? params[:customer2][:id] : params[:customer1][:id])
  end

  def check_for_customer
    unless params[:customer1].present? and params[:customer2].present?
      flash[:error] = "No Customer Selected"
      redirect_to request.referrer
    end
  end

  def build_credentials(field, customer_hash, customer)
    customer_hash[field].each do |key, value|
      customer.send("#{field}").build(value)
    end
  end

  def save_changes(field, customers, customer)
    @objects = field.classify.constantize.find_all_by_id(customers["#{field.intern}"])
    @objects.each do |object|
      unless object.customer_id == customer.id
        customer.send("#{field}") << object
      end
    end
  end

  def generate_csv_array(column_names, customer)
    if column_names.include?("name")
      name = customer.name
    end
    if column_names.include?("emails")
      emails = customer.emails.collect(&:address).join(", ")
    end
    if column_names.include?("phone_numbers")
      phone_numbers = customer.phone_numbers.collect(&:phone).join(", ")
    end
    if column_names.include?("address")
      address = customer.address.complete_address
    end
    if column_names.include?("special_note")
      special_note = customer.special_note.description
    end
    temp_array = []
    column_names.map { |col| temp_array << [eval(col)] }
    temp_array
  end
end
