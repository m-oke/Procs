class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  self.primary_key = :id_number

  has_many :user_lessons, :foreign_key => :id_number
  has_many :lessons, :through => :user_lessons

  has_many :answers, :foreign_key => :student_id_number
  has_many :questions, :through => :answers

  enum role: {faculty: 0, student: 1}

end
