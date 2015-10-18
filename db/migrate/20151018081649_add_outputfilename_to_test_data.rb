class AddOutputfilenameToTestData < ActiveRecord::Migration
  def change
    add_column :test_data, :OutputFilename, :String
  end
end
