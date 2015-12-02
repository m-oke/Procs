class AddIsDeletedToQuestionKeyword < ActiveRecord::Migration
  def change
    add_column :question_keywords, :is_deleted, :boolean, :default => false, :null => true
  end
end
