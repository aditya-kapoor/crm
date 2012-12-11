class CreateSpecialNotes < ActiveRecord::Migration
  def change
    create_table :special_notes do |t|
      t.text :description
      t.belongs_to :customer
      t.timestamps
    end
  end
end
