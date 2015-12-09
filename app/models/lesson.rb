# -*- coding: utf-8 -*-
class Lesson < ActiveRecord::Base
  validates :name, :presence => true
  validates :lesson_code, :presence => true, :uniqueness => true


  has_many :questions

  has_many :user_lessons, :foreign_key => :lesson_id
  has_many :user, :through => :user_lessons

  has_many :lesson_questions, :foreign_key => :lesson_id
  has_many :question, :through => :lesson_questions

  has_many :answers, :foreign_key => :lesson_id

  attr_accessor :teacher


  rails_admin do
    show do
      field :description
      field :lesson_code
      # TODO: teacherの表示
      field :teacher do
        pretty_value do
          UserLesson.find_by(:lesson_id => bindings[:object].id, :is_teacher => true).user.name.to_s
          bindings[:object].id
        end
      end
      field :user
      field :question
    end

    create do
      field :name do
        required true
      end
      field :description
      field :lesson_code do
        required true
      end
      #TODO: is_teacherを設定できるように
      field :teacher, :enum do
        required true
        enum do
          User.all.collect do |u|
            if u.has_role?(:teacher)
              [u.name, u.id]
            end
          end
        end
      end
      field :user
      field :question
    end

    edit do
      field :name do
        required true
      end
      field :description
      field :lesson_code do
        required true
        help "授業に参加するためのコード, #{help}"
      end
      field :user
      field :question
    end
  end
end
