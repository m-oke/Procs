class CreateLocalCheckResults < ActiveRecord::Migration
  def change
    create_table :local_check_results do |t|
      t.integer :answer_id, null: false
      t.float :check_result, default: 0
      t.string :target_name
      t.string :compare_name
      t.string :target_line
      t.string :compare_line
      t.string :compare_path
      t.integer :compare_user_id
      t.integer :compare_lesson_question_id
      t.timestamps null: false
    end
  end
end
