require 'validation_patterns'

class Email < ActiveRecord::Base
  include ValidationPatterns
  attr_accessible :address, :email_type
  belongs_to :customer

  validates :address, :format => { :with => PATTERNS['email'], :message => "This email has incorrect pattern" }
  validates :email_type, :presence => {:message => "You must enter the email type on entering the email"}, :if => :address

  TYPE = { "Personal" => "Personal", "Official" => "Official" }

  after_save :set_customer_delta_flag
  after_destroy :set_customer_delta_flag

  private

  def set_customer_delta_flag
    customer.delta = true
    customer.save
  end
end
