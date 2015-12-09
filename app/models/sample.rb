# -*- coding: utf-8 -*-
class Sample < ActiveRecord::Base
  belongs_to :question, :foreign_key => :question_id

  rails_admin do
    parent Question
    create do
      field :question do
        required true
        help "関連を付ける問題, #{help}"
      end
      field :input do
        required true
      end
      field :output do
        required true
      end
    end

    edit do
      field :question do
        required true
      end
      field :input do
        required true
      end
      field :output do
        required true
      end
      field :is_deleted do
        help "非公開にしたサンプルデータは表示されません, #{help}"
      end
    end
  end

end
