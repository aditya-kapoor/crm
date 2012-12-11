class Address < ActiveRecord::Base
  attr_accessible :city, :line1, :line2, :state, :zip, :country
  belongs_to :customer

  after_save :set_customer_delta_flag
  after_destroy :set_customer_delta_flag

  private

  def set_customer_delta_flag
    customer.delta = true
    customer.save
  end
end