class CreateTestData < ActiveRecord::Migration
  def change
    create_table :test_data do |t|
      t.integer :question_id, null: false
      t.string :input, limit:1024, null: false
      t.string :output, limit:1024, null: false

      t.timestamps null: false
    end
  end
end
