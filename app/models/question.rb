class Question < ActiveRecord::Base
  belongs_to :lesson

  has_many :samples
  has_many :test_data
  has_many :answers
  has_many :users, :through => :answers
end
