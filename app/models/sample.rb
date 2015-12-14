# -*- coding: utf-8 -*-
class Sample < ActiveRecord::Base
  belongs_to :question, :foreign_key => :question_id

  validates :question, :presence => true
  validates :input, :presence => true
  validates :output, :presence => true

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
        help "関連を付ける問題, 問題作成時は選択する必要はありません, #{help}"
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

    list do
      field :id
      field :question
      field :input
      field :output
      field :is_deleted
      field :created_at
      field :updated_at
    end

  end

end
