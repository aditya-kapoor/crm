class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :username, :password, :password_confirmation, :remember_me
  # attr_accessible :username, :password, :password_confirmation
  attr_protected :super_admin

  # has_secure_password

  # validates :password, :length => { :minimum => 6 }
  # validates :password_confirmation, :presence => true, :if => :password
end
