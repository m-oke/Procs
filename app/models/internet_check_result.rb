# -*- coding: utf-8 -*-
class InternetCheckResult < ActiveRecord::Base
  belongs_to :answer, :foreign_key => :answer_id

  rails_admin do
    create do
      field :answer_id, :enum do
        enum do
          Answer.all.collect do |a|
            ["[#{a.lesson.name}] - [#{a.question.title} - #{a.user.nickname}] ##{a.file_name[0..7]}", a.id]
          end
        end

        required true
      end
      field :title
      field :link
      field :content
      field :repeat do
        help "繰り返し検索してヒットした回数, #{help}"
      end
    end

    edit do
      field :answer_id, :enum do
        enum do
          Answer.all.collect do |a|
            ["[#{a.lesson.name}] - [#{a.question.title} - #{a.user.nickname}] ##{a.file_name[0..7]}", a.id]
          end
        required true
        end
      end
      field :title
      field :link
      field :content
      field :repeat do
        help "繰り返し検索してヒットした回数, #{help}"
      end
    end
  end

end
