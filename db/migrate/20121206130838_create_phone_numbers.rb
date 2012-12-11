class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.string :phone
      t.string :phone_type
      t.belongs_to :customer
      t.timestamps
    end
  end
end
