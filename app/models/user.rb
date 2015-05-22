class User < ActiveRecord::Base
  has_many :user_lessons
  has_many :lessons, through: :user_lessons

  has_many :answers
  has_many :questions, through: :answers

end
