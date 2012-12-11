class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :line1
      t.string :line2
      t.string :state
      t.string :city
      t.string :zip
      t.belongs_to :customer
      t.timestamps
    end
  end
end
