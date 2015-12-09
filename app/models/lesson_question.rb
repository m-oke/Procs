# -*- coding: utf-8 -*-
class LessonQuestion < ActiveRecord::Base
  belongs_to :lesson, :foreign_key => :lesson_id
  belongs_to :question, :foreign_key => :question_id

  rails_admin do
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
    end
  end

end
