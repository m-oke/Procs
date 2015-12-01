class AddUseLessonQuestionToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :lesson_question_id, :integer, :null => false
  end
end
