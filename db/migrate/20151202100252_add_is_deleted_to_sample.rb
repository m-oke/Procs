class AddIsDeletedToSample < ActiveRecord::Migration
  def change
    add_column :samples, :is_deleted, :boolean, :default => false, :null => false
  end
end
