class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  self.primary_key = :id_number

  has_many :user_lessons
  has_many :lessons, :through => :user_lessons

  has_many :answers
  has_many :questions, :through => :answers

end
