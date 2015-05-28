class Question < ActiveRecord::Base
  belongs_to :lessons

  has_many :samples
  has_many :test_data
  has_and_belongs_to_many :answers
end
