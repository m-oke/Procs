class AddCloseToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :close, :string
  end
end
