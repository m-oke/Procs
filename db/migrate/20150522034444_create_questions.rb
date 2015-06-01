class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title, null: false
      t.integer :class_id, null: false
      t.string :content
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.string :input_description
      t.string :output_description
      t.integer :run_time_limit
      t.integer :memory_usage_limit
      t.integer :cpu_usage_limit

      t.timestamps null: false
    end
  end
end
