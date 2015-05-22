class Lesson < ActiveRecord::Base
  has_many :user_lessons
  has_many :users, through: :user_lessons

  has_many :questions
end
