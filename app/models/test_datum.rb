# -*- coding: utf-8 -*-
class TestDatum < ActiveRecord::Base
  belongs_to :question, :foreign_key => :question_id

  rails_admin do
    parent Question
    create do
      field :question do
        required true
        help "関連付ける問題, 問題作成時は選択する必要はありません, #{help}"
      end
      # ファイルアップロード機能
      field :input do
        required true
        help "入力データのアップロード時のファイル名, #{help}"
      end
      field :output do
        required true
        help "出力データのアップロード時のファイル名, #{help}"
      end
      field :input_storename do
        required true
        help "サーバに保存した入力データのファイル名, #{help}"
      end
      field :output_storename do
        required true
        help "サーバに保存した出力データのファイル名, #{help}"
      end
    end

    edit do
      field :question do
        required true
        help "関連付ける問題, #{help}"
      end
      field :input do
        required true
        help "入力データのアップロード時のファイル名, #{help}"
      end
      field :output do
        required true
        help "出力データのアップロード時のファイル名, #{help}"
      end
      field :input_storename do
        required true
        help "サーバに保存した入力データのファイル名, #{help}"
      end
      field :output_storename do
        required true
        help "サーバに保存した出力データのファイル名, #{help}"
      end
      field :is_deleted do
        help "非公開にしたテストデータは評価時に利用されません, #{help}"
      end
    end

    list do
      field :id
      field :question
      field :input
      field :output
      field :input_storename
      field :output_storename
      field :is_deleted
      field :created_at
      field :updated_at
    end

    show do
      field :question
      field :input do
      end
      field :output
      field :input_storename
      field :output_storename
      field :is_deleted
    end
  end
end
