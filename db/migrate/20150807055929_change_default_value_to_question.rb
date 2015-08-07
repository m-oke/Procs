class ChangeDefaultValueToQuestion < ActiveRecord::Migration
  def change
    change_column :questions, :run_time_limit, :integer, :default => 60000
  end
end
