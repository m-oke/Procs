class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, :id => false do |t|
      t.primary_key :id_number
      t.string :name
      t.string :mail
      t.string :faculty
      t.string :department
      t.integer :grade
      t.integer :role
      t.boolean :admin
      t.string :password

      t.timestamps null: false
    end
  end
end
