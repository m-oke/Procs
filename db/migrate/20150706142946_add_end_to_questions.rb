class AddEndToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :end, :string
  end
end
