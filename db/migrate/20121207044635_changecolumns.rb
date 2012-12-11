class Changecolumns < ActiveRecord::Migration
  def up
    rename_column :customers, :designation, :salutation
  end

  def down
    rename_column :customers, :salutation, :designation
  end
end
