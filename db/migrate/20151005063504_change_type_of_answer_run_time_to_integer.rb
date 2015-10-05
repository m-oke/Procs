class ChangeTypeOfAnswerRunTimeToInteger < ActiveRecord::Migration
  def change
    change_column :answers, :run_time, :float, :default => 0
  end
end
