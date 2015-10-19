class AddColumnToTestData < ActiveRecord::Migration
  def change
    add_column :test_data, :input_filename, :string, null: true
    add_column :test_data, :output_filename, :string, null: true
  end
end
