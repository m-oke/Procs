class CreateTestData < ActiveRecord::Migration
  def change
    create_table :test_data do |t|
      t.integer :question_id, null: false
      t.string :input
      t.string :output

      t.timestamps null: false
    end
  end
end
