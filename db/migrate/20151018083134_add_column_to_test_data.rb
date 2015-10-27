class AddColumnToTestData < ActiveRecord::Migration
  def change
    add_column :test_data, :input_storename, :string, null: true
    add_column :test_data, :output_storename, :string, null: true
  end
end
