class Question < ActiveRecord::Base
  has_many :answers
  has_many :users, through: :answers

  belongs_to :lessons

  has_many :samples
  has_many :test_data
end
