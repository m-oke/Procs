# -*- coding: utf-8 -*-
class QuestionKeyword < ActiveRecord::Base
  belongs_to :question, :foreign_key => :question_id

  validates :question, :presence => true
  validates :keyword, :presence => true

  rails_admin do
    weight 6
    parent Question

    create do
      field :question do
        required true
        help "関連を付ける問題, #{help}"
      end
      field :keyword do
        required true
        help "剽窃チェックに利用する検索キーワード, #{help}"
      end
    end

    edit do
      field :question do
        required true
        help "関連を付ける問題, 問題作成時は選択する必要はありません, #{help}"
      end
      field :keyword do
        required true
        help "剽窃チェックに利用する検索キーワード, #{help}"
      end
    end

  end
end
