class AddColumnToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :lesson_id, :integer
  end
end
