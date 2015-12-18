class ChangeTypeOfSampleDataToText < ActiveRecord::Migration
  def change
    change_column :samples, :input, :text, :null => false
    change_column :samples, :output, :text, :null => false
  end
end
