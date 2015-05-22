class CreateUserLessons < ActiveRecord::Migration
  def change
    create_table :user_lessons do |t|
      t.string :id_number
      t.integer :class_id

      t.timestamps null: false
    end
  end
end
