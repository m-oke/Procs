class CreateUserLessons < ActiveRecord::Migration
  def change
    create_table :user_lessons do |t|
      t.string :id_number, null: false
      t.integer :lesson_id, null: false

      t.timestamps null: false
    end
  end
end
