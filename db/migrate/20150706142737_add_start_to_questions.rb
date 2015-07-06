class AddStartToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :start, :string
  end
end
