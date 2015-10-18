class AddInputfilenameToTestData < ActiveRecord::Migration
  def change
    add_column :test_data, :InputFilename, :String
  end
end
