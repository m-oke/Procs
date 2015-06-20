class Question < ActiveRecord::Base
  belongs_to :lesson

  has_many :samples, :foreign_key => :question_id
  has_many :test_data, :foreign_key => :question_id
  has_many :answers, :foreign_key => :question_id

  accepts_nested_attributes_for :samples
  accepts_nested_attributes_for :test_data
end
