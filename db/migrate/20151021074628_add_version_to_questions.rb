class AddVersionToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :version, :integer
  end
end
