class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.string :student_id_number, null: false
      t.integer :question_id, null: false
      t.string :file_name, null: false
      t.integer :result, null: false
      t.language :language, null: false
      t.decimal :run_time
      t.integer :memory_usage
      t.integer :cpu_usage
      t.float :plagiarism_percentage

      t.timestamps null: false
    end
  end
end
