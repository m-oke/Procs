class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :name, null: false
      t.string :description
      t.string :term
      t.string :date
      t.string :period

      t.timestamps null: false
    end
  end
end
