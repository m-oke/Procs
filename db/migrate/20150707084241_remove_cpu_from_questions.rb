class RemoveCpuFromQuestions < ActiveRecord::Migration
  def change
    remove_column :questions, :cpu_usage_limit
  end
end
