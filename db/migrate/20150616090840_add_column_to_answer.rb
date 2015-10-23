class AddColumnToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :lesson_id, :integer
    add_column :answers, :question_version, :integer
  end
end
