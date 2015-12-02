class AddIsDeleteToLessonQuestions < ActiveRecord::Migration
  def change
    add_column LessonQuestion,:is_deleted,  :boolean,  :default => false
  end
end
