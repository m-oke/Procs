class AddDefaultValueToVersionOfQuestion < ActiveRecord::Migration
  def change
    change_column :questions, :version, :integer, :default => 1
  end
end
