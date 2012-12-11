class Admin < ActiveRecord::Base
  attr_accessible :username, :password, :password_confirmation
  attr_protected :super_admin

  has_secure_password

  validates :password, :length => { :minimum => 6 }
  validates :password_confirmation, :presence => true, :if => :password
end
