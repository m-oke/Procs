class AddColumnToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :lesson_code, :string, null: false
  end
end
