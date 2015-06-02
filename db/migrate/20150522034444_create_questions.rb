class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title, null: false
      t.integer :lesson_id, null: false
      t.binary :content, :limit => 1000.kilobyte
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.binary :input_description, :limit => 1000.kilobyte
      t.binary :output_description, :limit => 1000.kilobyte
      t.integer :run_time_limit
      t.integer :memory_usage_limit
      t.integer :cpu_usage_limit

      t.timestamps null: false
    end
  end
end
