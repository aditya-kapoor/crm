class SpecialNote < ActiveRecord::Base
  attr_accessible :description
  belongs_to :customer
end
