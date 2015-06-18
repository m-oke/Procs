class UserLesson < ActiveRecord::Base
  belongs_to :user, :foreign_key => :user_id
  belongs_to :lesson, :foreign_key => :lesson_id
end
