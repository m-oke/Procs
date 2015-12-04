class AddIsDeletedToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :is_deleted, :boolean ,:default=>false, :null=>false
  end
end
