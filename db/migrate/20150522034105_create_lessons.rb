class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :name, null: false
      t.text :description
      t.string :term
      t.integer :date
      t.string :period

      t.timestamps null: false
    end
  end
end
