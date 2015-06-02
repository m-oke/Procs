class UserLesson < ActiveRecord::Base
  belongs_to :user, :foreign_key => :id_number
  belongs_to :lesson, :foreign_key => :lesson_id
end
