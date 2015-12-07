class ChangeDefaultsUserRoll < ActiveRecord::Migration
  def change
    change_column :users, :roles_mask, :integer, :default => 8
  end
end
