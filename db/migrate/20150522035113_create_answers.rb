class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :student_id, null: false
      t.integer :question_id, null: false
      t.string :file_name, null: false
      t.string :result, null: false
      t.string :language, null: false
      t.float :run_time, default: 0
      t.integer :memory_usage, default: 0
      t.integer :cpu_usage, default: 0
      t.float :local_plagiarism_percentage, default: 0

      t.timestamps null: false
    end
  end
end
