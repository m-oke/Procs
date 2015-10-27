class RemoveNullRestrictToTestData < ActiveRecord::Migration
  def change
      change_column :test_data, :question_id, :integer, :null => true
  end
end
