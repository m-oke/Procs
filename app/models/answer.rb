# -*- coding: utf-8 -*-
class Answer < ActiveRecord::Base
  # user_id belong
  belongs_to :user, :foreign_key => :student_id

  belongs_to :question, :foreign_key => :question_id
  belongs_to :lesson, :foreign_key => :lesson_id
  belongs_to :lesson_question, :foreign_key => :lesson_question_id

  # user_id validate
  validates :user, :presence => true

  validates :question, :presence => true
  validates :lesson, :presence => true
  validates :lesson_question, :presence => true

  # file_name validate
  validates :file_name, :presence => true,
  :format => {:with => /\A[!-~]{1,255}\z/, :message => 'は適切なフォーマットではありません' }
  validates :language, :presence => true
  validates :run_time, :presence => true
  validates :memory_usage, :presence => true
  validates :question_version, :presence => true
  validates :test_count, :presence => true
  validates :test_passed, :presence => true
  validates :result, :presence => true
  validates :local_plagiarism_percentage, :presence => true


  has_many :internet_check_results, :foreign_key => :answer_id
  has_many :local_check_results, :foreign_key => :answer_id
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

  # 入力されたlanguageが正しいかどうかの検証
  def include_language
    unless LANGUAGE.include?(language.camelize)
    end
  end

  # TODO: controllerの登録でカスタマイズが可能?
  # https://github.com/sferik/rails_admin/blob/master/lib/rails_admin/config/actions/edit.rb
  # TODO: createアクションは必要だろうか？
  rails_admin do
    weight 4
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
      field :lesson_question_id, :enum do
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
      field :language, :enum do
        required true
        enum do
          LANGUAGES.collect { |l| ["#{l}", l.downcase]}
        end
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
      field :result, :enum do
        required true
        help "評価結果, #{help}"
        enum do
          RESULT.collect {|k,v| ["#{v}", k]}
        end
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
      field :lesson_question_id, :enum do
        enum do
          LessonQuestion.all.collect {|lq| ["[#{lq.lesson.name}] - [#{lq.question.title}] ##{lq.id}", lq.id]}
        end
        required true
        help "解答した問題と授業の関連, コピーした問題がある場合は注意, #{help}"
      end
      field :file_name do
        read_only true
        help "サーバに保存した解答ソースコードのファイル名"
      end
      field :language, :enum do
        required true
        enum do
          LANGUAGES.collect { |l| ["#{l}", l.downcase]}
        end
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
      field :result, :enum do
        required true
        help "評価結果, #{help}"
        enum do
          RESULT.collect {|k,v| ["#{v}", k]}
        end
      end
      field :local_plagiarism_percentage do
        help "学生間のソースコードの類似度, #{help}"
      end
      field :internet_check_results do
        help "Web上のソースコードとの類似度"
      end
    end

    list do
      field :id
      field :user
      field :question
      field :lesson
      field :lesson_question do
        pretty_value do
          val = "[#{value.lesson.name}] - [#{value.question.title}] : ##{value.id}"
          bindings[:view].link_to val, bindings[:view].rails_admin.show_path('lesson_question', value.id)
        end
      end
      field :result do
        formatted_value do
          RESULT[value]
        end
      end
      field :file_name
      field :language
      field :run_time
      field :memory_usage
      field :question_version
      field :test_countn
      field :test_passed
      field :local_plagiarism_percentage
      field :internet_check_results
      field :created_at
      field :updated_at
    end

    show do
      field :id
      field :user
      field :question
      field :lesson
      field :lesson_question do
        pretty_value do
          val = "[#{value.lesson.name}] - [#{value.question.title}] : ##{value.id}"
          bindings[:view].link_to val, bindings[:view].rails_admin.show_path('lesson_question', value.id)
        end
      end
      field :result do
        formatted_value do
          RESULT[value]
        end
      end
      field :file_name
      field :language
      field :run_time
      field :memory_usage
      field :question_version
      field :test_count
      field :test_passed
      field :local_plagiarism_percentage
      field :internet_check_results
      field :created_at
      field :updated_at
    end
  end

end
