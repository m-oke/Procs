class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.integer :question_id, null: false
      t.string :input, null: false
      t.string :output, null: false

      t.timestamps null: false
    end
  end
end
