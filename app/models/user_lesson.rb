# -*- coding: utf-8 -*-
class UserLesson < ActiveRecord::Base
  belongs_to :user, :foreign_key => :user_id
  belongs_to :lesson, :foreign_key => :lesson_id

  validates :user, :presence => true
  validates :lesson, :presence => true

  rails_admin do
    parent Lesson

    create do
      field :user do
        required true
        help "参加させるユーザ, #{help}"
      end
      field :lesson do
        required true
        help "参加させる授業, #{help}"
      end
      field :is_teacher do
        help "該当する教員をその授業の担当とする設定, teacher権限を持つユーザ以外は設定しないでください, #{help}"
      end
    end

    edit do
      field :user do
        required true
        help "参加させるユーザ, #{help}"
      end
      field :lesson do
        required true
        help "参加させる授業, #{help}"
      end
      field :is_teacher do
        help "該当する教員をその授業の担当とする設定, teacher権限を持つユーザ以外は設定しないでください, #{help}"
      end
      field :is_deleted do
        help "ユーザをその授業から脱退させる設定, #{help}"
      end
    end

    list do
      field :id
      field :user
      field :lesson
      field :is_teacher
      field :is_deleted
      field :created_at
      field :updated_at
    end

  end
end
