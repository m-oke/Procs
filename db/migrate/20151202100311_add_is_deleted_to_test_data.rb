class AddIsDeletedToTestData < ActiveRecord::Migration
  def change
    add_column :test_data, :is_deleted, :boolean, :default => false, :null => false
  end
end
