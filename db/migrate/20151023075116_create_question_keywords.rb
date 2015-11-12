class CreateQuestionKeywords < ActiveRecord::Migration
  def change
    create_table :question_keywords do |t|
      t.integer :question_id, null: false
      t.string :keyword
      t.timestamps null: false
    end
  end
end
