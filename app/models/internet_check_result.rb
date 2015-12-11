# -*- coding: utf-8 -*-
class InternetCheckResult < ActiveRecord::Base
  belongs_to :answer, :foreign_key => :answer_id

  rails_admin do
    weight 5
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

    list do
      field :id
      field :answer do
        column_width 300
        pretty_value do
          val = "[#{value.lesson.name}] - [#{value.question.title} - #{value.user.nickname}] ##{value.file_name[0..7]}"
          bindings[:view].link_to val, bindings[:view].rails_admin.show_path('answer', value.id)
        end
      end
      field :title
      field :link
      field :content
      field :repeat
      field :created_at
      field :updated_at
    end


  end
p

end
