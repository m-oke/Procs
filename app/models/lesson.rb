# -*- coding: utf-8 -*-
class Lesson < ActiveRecord::Base
  validates :name, :presence => true

  validates :lesson_code, :presence => true, :uniqueness => true,
  :format => {:with => /\A[!-~]{1,255}\z/, :message => 'は適切なフォーマットではありません' }

  has_many :questions

  has_many :user_lessons, :foreign_key => :lesson_id
  has_many :users, :through => :user_lessons

  has_many :lesson_questions, :foreign_key => :lesson_id
  has_many :questions, :through => :lesson_questions

  has_many :answers, :foreign_key => :lesson_id


  rails_admin do
    weight 2
    show do
      field :description
      field :lesson_code
      # TODO: teacherの表示
      field :users
      field :questions
    end

    create do
      field :name do
        required true
      end
      field :description
      field :lesson_code do
        required true
        help "学生が授業に参加する際に入力するコード, #{help}"
      end
      field :users do
        help "ここでは参加する学生を設定できます．この授業を担当する教員は別途「授業の参加」から作成してください，#{help}"
      end
      field :questions
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
      field :users
      field :questions
    end

    list do
      field :id
      field :name
      field :description
      field :lesson_code
      field :users do
        help "ここでは参加する学生を設定できます．この授業を担当する教員は別途「授業の参加」から作成してください，#{help}"
      end
      field :questions
      field :created_at
      field :updated_at
    end
  end
end
