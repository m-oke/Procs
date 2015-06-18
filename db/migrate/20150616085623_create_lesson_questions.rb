class CreateLessonQuestions < ActiveRecord::Migration
  def change
    create_table :lesson_questions do |t|
      t.integer :lesson_id, null: false
      t.integer :question_id, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time

      t.timestamps null: false
    end
  end
end
