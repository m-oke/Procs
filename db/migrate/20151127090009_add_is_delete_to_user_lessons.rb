class AddIsDeleteToUserLessons < ActiveRecord::Migration
  def change
    add_column :user_lessons, :is_deleted, :integer ,:default=>0
  end
end
