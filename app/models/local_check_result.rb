# -*- coding: utf-8 -*-
class LocalCheckResult < ActiveRecord::Base
  belongs_to :answer, :foreign_key => :answer_id
  belongs_to :user, :foreign_key => :compare_user_id
  belongs_to :lesson_question, :foreign_key => :compare_lesson_question_id

  rails_admin do
    weight 5

    edit do
      field :answer_id, :enum do
        enum do
          Answer.all.collect do |a|
            ["[#{a.lesson.name}] - [#{a.question.title} - #{a.user.nickname}] ##{a.file_name[0..7]}", a.id]
          end
        end
        required true
      end
      field :check_result
      field :target_name
      field :compare_name
      field :target_line
      field :compare_line
      field :compare_path
      field :compare_user_id
      field :compare_lesson_question_id

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
      field :check_result
      field :target_name
      field :compare_name
      field :target_line
      field :compare_line
      field :compare_path
      field :compare_user_id
      field :compare_lesson_question_id
      field :created_at
      field :updated_at
    end


  end

end
