# -*- coding: utf-8 -*-
class Answer < ActiveRecord::Base
  belongs_to :user, :foreign_key => :student_id
  belongs_to :question, :foreign_key => :question_id
  belongs_to :lesson, :foreign_key => :lesson_id
  belongs_to :lesson_question, :foreign_key => :lesson_question_id

  has_many :internet_check_results, :foreign_key => :answer_id
  # 最新の解答を取得
  # @param [Fixnum] student_id
  # @param [Fixnum] lesson_id
  # @param [Fixnum] question_id
  def self.latest_answer(student_id:, lesson_id:, question_id:, lesson_question_id:)
    answers = Answer.where(:student_id => student_id,
                           :question_id => question_id,
                           :lesson_id => lesson_id,
                           :lesson_question_id => lesson_question_id)
    latest_answer = nil
    unless answers.empty?
      last = answers.where(:result => ["A", "P"]).last
      latest_answer = last.nil? ? answers.last : last
    end
    return latest_answer
  end

  # 最新のAcceptの解答を取得
  # @param [Fixnum] student_id
  # @param [Fixnum] lesson_id
  # @param [Fixnum] question_id
  def self.accept_answer(student_id:, lesson_id:, question_id:, lesson_question_id:)
    return Answer.where(:student_id => student_id,
                        :question_id => question_id,
                        :lesson_id => lesson_id,
                        :result => "A",
                        :lesson_question_id => lesson_question_id).last
  end

  # 該当する授業と学生の成績を取得
  # @param [Fixnum] student_id
  # @param [Fixnum] lesson_id
  def self.records(student_id:, lesson_id:, lesson_questions:nil)
    lesson_questions = lesson_questions ? lesson_questions : LessonQuestion.where(:lesson_id => lesson_id)
    accept_count = 0

    lesson_questions.each do |lesson_question|
      answer = Answer.accept_answer(:student_id => student_id,
                                    :lesson_id => lesson_id,
                                    :question_id => lesson_question.question_id,
                                    :lesson_question_id => lesson_question.id)
      if answer.present?
        accept_count += 1
      end
    end
    return accept_count
  end


  rails_admin do
    create do
      field :user do
        required true
      end
      field :question do
        required true
      end
      field :lesson do
        required true
      end
      field :lesson_question, :enum do
        enum do
          LessonQuestion.all.collect {|lq| ["[#{lq.lesson.name}] - [#{lq.question.title}] ##{lq.id}", lq.id]}
        end
        required true
        help "解答した問題と授業の関連, コピーした問題がある場合は注意, #{help}"
      end
      # TODO: ファイルアップロード機能
      field :file_name do
        required true
        help "サーバに保存した解答ソースコードのファイル名, #{help}"
      end
      field :language do
        required true
        help "cまたはpython, #{help}"
      end
      field :run_time do
        help "単位はms, #{help}"
      end
      field :memory_usage do
        help "単位はMB, #{help}"
      end
      field :question_version do
        required true
        help "解答した問題のバージョン, #{help}"
      end
      field :test_count
      field :test_passed
      field :result do
        required true
        res = ""
        RESULT.each_with_index do |(key, val), i|
          res += "#{key} => #{val}"
          if (i + 1 != RESULT.size)
            res += ", "
          end
        end
        help "評価結果, 対応表(#{res}), #{help}"
      end
      field :plagiarism_percentage do
        help "学生間のソースコードの類似度, #{help}"
      end
      field :internet_check_results do
        help "Web上のソースコードとの類似度"
      end
    end

    edit do
      field :user do
        required true
      end
      field :question do
        required true
      end
      field :lesson do
        required true
      end
      field :lesson_question, :enum do
        enum do
          LessonQuestion.all.collect {|lq| ["[#{lq.lesson.name}] - [#{lq.question.title}] ##{lq.id}", lq.id]}
        end
        required true
        help "解答した問題と授業の関連, コピーした問題がある場合は注意, #{help}"
      end
      field :file_name do
        required true
        help "サーバに保存した解答ソースコードのファイル名, #{help}"
      end
      field :language do
        required true
        help "cまたはpython, #{help}"
      end
      field :run_time do
        help "単位はms, #{help}"
      end
      field :memory_usage do
        help "単位はMB, #{help}"
      end
      field :question_version do
        required true
        help "解答した問題のバージョン, #{help}"
      end
      field :test_count
      field :test_passed
      field :result do
        required true
        res = ""
        RESULT.each_with_index do |(key, val), i|
          res += "#{key} => #{val}"
          if (i + 1 != RESULT.size)
            res += ", "
          end
        end
        help "評価結果, 対応表(#{res}), #{help}"
      end
      field :plagiarism_percentage do
        help "学生間のソースコードの類似度, #{help}"
      end
      field :internet_check_results do
        help "Web上のソースコードとの類似度"
      end
    end
  end

end
