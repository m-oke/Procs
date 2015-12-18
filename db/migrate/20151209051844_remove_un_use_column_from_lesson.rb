class RemoveUnUseColumnFromLesson < ActiveRecord::Migration
  def change
    remove_column :lessons, :term
    remove_column :lessons, :date
    remove_column :lessons, :period
  end
end
