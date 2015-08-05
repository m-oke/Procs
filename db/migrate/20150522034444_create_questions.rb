class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title, :null => false
      t.text :content
      t.text :input_description
      t.text :output_description
      t.integer :run_time_limit, :default => 60
      t.integer :memory_usage_limit, :default => 512
      t.integer :cpu_usage_limit

      t.timestamps null: false
    end
  end
end
