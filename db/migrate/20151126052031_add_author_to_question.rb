class AddAuthorToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :author, :integer, null: false
  end
end
