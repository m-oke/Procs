class UserLesson < ActiveRecord::Base
  belongs_to :users
  belongs_to :lessons
end
