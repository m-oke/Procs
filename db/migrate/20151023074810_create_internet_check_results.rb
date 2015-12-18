class CreateInternetCheckResults < ActiveRecord::Migration
  def change
    create_table :internet_check_results do |t|
      t.integer :answer_id, null: false
      t.string :title
      t.string :link
      t.text   :content
      t.integer :repeat
      t.string :key_word
      t.timestamps null: false
    end
  end
end
