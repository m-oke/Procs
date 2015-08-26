class AddTestPassedToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :test_passed, :integer, :null => false, :default => 0
    add_column :answers, :test_count, :integer, :null => false, :default => 0
  end
end
