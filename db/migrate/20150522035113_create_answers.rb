class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.string :student_id_number
      t.integer :question_id
      t.string :file_name
      t.integer :result
      t.decimal :run_time
      t.integer :memory_usage
      t.float :plagiarism_percentage

      t.timestamps null: false
    end
  end
end
