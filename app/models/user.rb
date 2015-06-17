class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_lessons, :foreign_key => :user_id
  has_many :lessons, :through => :user_lessons

  has_many :answers, :foreign_key => :student_id
  has_many :questions, :through => :answers

end
