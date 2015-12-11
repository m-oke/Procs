# -*- coding: utf-8 -*-
class LessonQuestion < ActiveRecord::Base
  belongs_to :lesson, :foreign_key => :lesson_id
  belongs_to :question, :foreign_key => :question_id
  has_many :answers, :foreign_key => :lesson_question_id

  rails_admin do
    parent Lesson
    weight 1
    create do
      field :lesson do
        required true
        help "関連付けを行う授業, #{help}"
      end
      field :question do
        required true
        help "関連付けを行う問題, #{help}"
      end
      field :start_time do
        help "問題に解答できる時間, #{help}"
      end
      field :end_time do
        help "問題に解答できる時間, #{help}"
      end
      # field :is_deleted do
      #   help "非公開設定, #{help}"
      # end
    end

    edit do
      field :lesson do
        required true
        help "関連付けを行う授業, #{help}"
      end
      field :question do
        required true
        help "関連付けを行う問題, #{help}"
      end
      field :start_time do
        help "問題に解答できる時間, #{help}"
      end
      field :end_time do
        help "問題に解答できる時間, #{help}"
      end
      field :answers
      # field :is_deleted do
      #   help "非公開設定, #{help}"
      # end

    end

    list do
      field :id
      field :lesson
      field :question
      field :start_time
      field :end_time
#      field :is_deleted
      field :answers
      field :created_at
      field :updated_at
    end
  end

end
