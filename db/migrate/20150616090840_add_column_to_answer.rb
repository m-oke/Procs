class AddColumnToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :lesson_id, :integer
    add_column :answers, :version, :integer
  end
end
