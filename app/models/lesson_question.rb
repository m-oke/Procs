class LessonQuestion < ActiveRecord::Base
  belongs_to :lesson, :foreign_key => :lesson_id
  belongs_to :question, :foreign_key => :question_id
end
