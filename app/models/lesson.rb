class Lesson < ActiveRecord::Base
  has_many :questions

#  has_and_belongs_to_many :users
  has_many :user_lessons, :foreign_key => :lesson_id
  has_many :user, :through => :user_lessons
end
