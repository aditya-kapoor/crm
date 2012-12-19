class PhoneNumber < ActiveRecord::Base
  attr_accessible :phone, :phone_type
  belongs_to :customer

  validates :phone, :length => { :is => 10 }, :allow_blank => true
  validates :phone, :numericality => { :only_integer => true }, :if => :phone
  validates :phone_type, :presence => { :message => "You must enter the phone type"}, :if => :phone

  TYPE = { "Mobile" => "Mobile", "Personal" => "Personal", "Business" => "Business", "Fax" => "Fax"}

  # def in_india?
  #   # phone.present? and address_attributes.country == "India"
  #   Rails.logger.info(self.inspect)
  #   false
  # end

  after_save :set_customer_delta_flag
  after_destroy :set_customer_delta_flag

  private

  def set_customer_delta_flag
    customer.delta = true
    customer.save
  end

end