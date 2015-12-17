class RemoveCpuUsageFromAnswer < ActiveRecord::Migration
  def change
    remove_column :answers, :cpu_usage
  end
end
