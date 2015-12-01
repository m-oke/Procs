class AddIsPublicToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :is_public, :boolean, null: false
  end
end
