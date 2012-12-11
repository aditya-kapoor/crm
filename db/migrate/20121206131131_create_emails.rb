class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :address
      t.string :email_type
      t.belongs_to :customer
      t.timestamps
    end
  end
end
