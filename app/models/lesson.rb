class Lesson < ActiveRecord::Base
  has_many :questions

  has_many :user_lessons, :foreign_key => :lesson_id
  has_many :user, :through => :user_lessons

  has_many :lesson_questions, :foreign_key => :lesson_id
  has_many :question, :through => :lesson_questions

  has_many :answers, :foreign_key => :lesson_id

end
