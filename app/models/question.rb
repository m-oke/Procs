class Question < ActiveRecord::Base
  has_many :lesson_questions, :foreign_key => :question_id
  has_many :lessons, :through => :lesson_questions

  has_many :samples, :foreign_key => :question_id
  has_many :test_data, :foreign_key => :question_id
  has_many :answers, :foreign_key => :question_id

  accepts_nested_attributes_for :samples,allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :test_data,allow_destroy:true, reject_if: :all_blank
end
