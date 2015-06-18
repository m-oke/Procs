class AddCoulumnToUserLesson < ActiveRecord::Migration
  def change
    add_column :user_lessons, :is_teacher, :boolean, :default => false, null: false
  end
end
