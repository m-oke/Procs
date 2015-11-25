class CreateLocalCheckResults < ActiveRecord::Migration
  def change
    create_table :local_check_results do |t|
      t.integer :answer_id, null: false
      t.float :check_result, default: 0
      t.string :check_file
      t.string :target_line
      t.string :compare_line
      t.timestamps null: false
    end
  end
end
