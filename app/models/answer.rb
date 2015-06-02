class Answer < ActiveRecord::Base
  belongs_to :user, :foreign_key => :student_id_number
  belongs_to :question
end
