class RemoveEndFromQuestions < ActiveRecord::Migration
  def change
    remove_column :questions, :end, :string
  end
end
