class Customer < ActiveRecord::Base
  attr_accessible :salutation, :first_name, :middle_name, :last_name
  attr_accessible :address_attributes, :special_note_attributes, :emails_attributes, :phone_numbers_attributes
  
  has_many :emails, :dependent => :destroy
  has_many :phone_numbers, :dependent => :destroy
  has_one :address, :dependent => :destroy
  has_one :special_note, :dependent => :destroy

  validates :first_name, :presence => true

  # validates :first_name, :uniqueness => { :scope => [:middle_name, :last_name], :message => "This name combination has already been taken" }

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :special_note
  accepts_nested_attributes_for :emails, :reject_if => lambda { |a| a[:address].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :phone_numbers, :reject_if => lambda { |a| a[:phone].blank? }, :allow_destroy => true

  SALUTATIONS = {"Mr." => "Mr.", "Mrs." => "Mrs.", "Dr." => "Dr.", "Sir" => "Sir", "Ms." => "Ms."}

  def name
    "#{salutation} #{first_name} #{middle_name} #{last_name}"
  end

  def to_param
    "#{id} #{name}".parameterize
  end

  def as_json(options = {})
    super(
      :include => [
        :address, :special_note, :emails, :phone_numbers
        ], 
      :methods => [:name],
      :except => [:salutation, :first_name, :middle_name, :last_name, :updated_at, :created_at])
  end

  define_index do 
    indexes first_name
    indexes middle_name
    indexes last_name
    indexes salutation
    indexes address(:country), :as => :country
    
    indexes emails.address, :as => :email_address
    indexes phone_numbers.phone, :as => :phone_numbers

    set_property :delta => true
  end
end
