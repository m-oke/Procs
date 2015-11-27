class AddIsDeleteToLessonQuestions < ActiveRecord::Migration
  def change
    add_column LessonQuestion,:is_deleted,  :integer,  :default => 0
  end
end
