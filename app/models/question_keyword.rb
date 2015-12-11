class QuestionKeyword < ActiveRecord::Base
  belongs_to :question, :foreign_key => :question_id

  rails_admin do
    weight 6
  end
end
