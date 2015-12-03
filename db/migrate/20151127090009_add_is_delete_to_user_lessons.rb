class AddIsDeleteToUserLessons < ActiveRecord::Migration
  def change
    add_column :user_lessons, :is_deleted, :boolean ,:default=>false, :null=>false
  end
end
