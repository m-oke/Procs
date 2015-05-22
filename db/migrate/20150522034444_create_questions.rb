class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title
      t.integer :class_id
      t.string :content
      t.datetime :start_time
      t.datetime :end_time
      t.string :input_description
      t.string :output_description
      t.integer :run_time_limit
      t.integer :memory_usage_limit

      t.timestamps null: false
    end
  end
end
