class AddDeltaToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :delta, :boolean, :default => true, :null => false
  end
end
