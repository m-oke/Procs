# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# root
User.create(:name => "root1", :nickname => "root", # :faculty => "研究科1", :department => "工学域1", :grade => 0,
            :email => "root@user.com", :email_confirmation => "root@user.com", :password => "testtest", :roles => [:root, :admin, :teacher, :student])

# 管理者
2.times do |i|
  User.create(:name => "管理者#{i + 1}", :nickname => "admin#{i+1}", # :faculty => "研究科1", :department => "工学域1", :grade => 0,
             :email => "Admin#{i + 1}@user.com", :email_confirmation => "Admin#{i + 1}@user.com", :password => "testtest", :roles => [:admin, :teacher, :student])
end


# 教師
3.times do |i|
    User.create(:name => "教員#{i + 1}", :nickname => "teacher#{i+1}", # :faculty => "工学域#{i + 1}", :department => "工学域#{i + 1}", :grade => 0,
                :email => "teacher#{i + 1}@user.com", :email_confirmation => "teacher#{i + 1}@user.com", :password => "testtest", :roles => [:teacher, :student])
end

# 学生
20.times do |i|
  if i < 9
    x = "0#{i + 1}"
  else
    x = "#{i + 1}"
  end
  User.create(:student_number => "2015200#{x}", :name => "学生#{i + 1}", :nickname => "student#{i+1}", #:faculty => "学部#{(i + 1) % 3 + 1}", :department => "学科#{(i + 1) % 2 + 1}", :grade => ((i + 1) % 4),
              :email => "student#{i + 1}@user.com", :email_confirmation => "student#{i + 1}@user.com", :password => "testtest", :roles => [:student])
end

# クラス
# すべての問題を含む，全員が参加するクラス
Lesson.create(:name => "All probrems", :description => "このクラスはすべての問題を含むクラスです。", :lesson_code => "0000000000")
# 授業コード 1010101, 1010102
2.times do |i|
  Lesson.create(:name => "講義#{i + 1}", :description => "説明#{i + 1}", :lesson_code => "101010#{i+1}")
end

# ユーザ:クラス
# すべての問題を含むクラス
UserLesson.create(:user_id => 1, :lesson_id => 1, :is_teacher => true)
25.times do |i|
  UserLesson.create(:user_id => i + 2, :lesson_id => 1, :is_teacher => false)
end

# 教師
2.times do |i|
  UserLesson.create(:user_id => i + 4, :lesson_id => i + 2, :is_teacher => true)
end

# 学生(user_id: 7~26)
15.times do |i|
  if i / 8 == 0
    UserLesson.create(:user_id => i + 7, :lesson_id => 2) # id:7~14
  else
    UserLesson.create(:user_id => i + 7, :lesson_id => 3) # id:15~21
  end
end

# 問題
# 過去の問題
Question.create(:title => "the 3n+1 problem",
                :content => "
Problems in Computer Science are often classified as belonging to a certain class of problems (e.g., NP, Unsolvable, Recursive). In this problem you will be analyzing a property of an algorithm whose classification is not known for all possible inputs.

The Problem

Consider the following algorithm:


1.  input n

2.  print n


3.  if n = 1 then STOP


4.   if n is odd then  tex2html_wrap_inline44


5.   else  tex2html_wrap_inline46


6.  GOTO 2



Given the input 22, the following sequence of numbers will be printed 22 11 34 17 52 26 13 40 20 10 5 16 8 4 2 1

It is conjectured that the algorithm above will terminate (when a 1 is printed) for any integral input value. Despite the simplicity of the algorithm, it is unknown whether this conjecture is true. It has been verified, however, for all integers n such that 0 < n < 1,000,000 (and, in fact, for many more numbers than this.)

Given an input n, it is possible to determine the number of numbers printed (including the 1). For a given n this is called the cycle-length of n. In the example above, the cycle length of 22 is 16.

For any two numbers i and j you are to determine the maximum cycle length over all numbers between i and j.",
                :input_description => "The input will consist of a series of pairs of integers i and j, one pair of integers per line. All integers will be less than 1,000,000 and greater than 0.
You should process all pairs of integers and for each pair determine the maximum cycle length over all integers between and including i and j.
You can assume that no operation overflows a 32-bit integer.",
                :output_description => "For each pair of input integers i and j you should output i, j, and the maximum cycle length for integers between and including i and j. These three numbers should be separated by at least one space with all three numbers on one line and with one line of output for each line of input. The integers i and j must appear in the output in the same order in which they appeared in the input and should be followed by the maximum cycle length (on the same line).",
                :version => 1,
                :run_time_limit => 5000,
                :memory_usage_limit => 256,
                :author => 4,
                :is_public => true)

# 現在の問題
Question.create(:title => "Financial Management",
                :content => "Larry graduated this year and finally has a job. He's making a lot of money, but somehow never seems to have enough. Larry has decided that he needs to grab hold of his financial portfolio and solve his financing problems. The first step is to figure out what's been going on with his money. Larry has his bank account statements and wants to see how much money he has. Help Larry by writing a program to take his closing balance from each of the past twelve months and calculate his average account balance.回答はhttp://blog.livedoor.jp/pcpp/archives/51190060.html",
                :input_description => "The input will be twelve lines. Each line will contain the closing balance of his bank account for a particular month. Each number will be positive and displayed to the penny. No dollar sign will be included.",
                :output_description => "The output will be a single number, the average (mean) of the closing balances for the twelve months. It will be rounded to the nearest penny, preceded immediately by a dollar sign, and followed by the end-of-line. There will be no other spaces or characters in the output.",
                :run_time_limit => 50000, :memory_usage_limit => 256, :version => 1, :author => 4, :is_public => false)

# 未来の問題
Question.create(:title => "問題3", :content => "問題3の内容", :input_description => "問題3の入力説明", :output_description => "問題3の出力説明",  :run_time_limit => 5, :memory_usage_limit => 256, :author => 4, :is_public => false)

# 現在の問題
Question.create(:title => "問題4", :content => "問題4の内容", :input_description => "問題4の入力説明", :output_description => "問題4の出力説明",  :run_time_limit => 5, :memory_usage_limit => 256, :author => 4, :is_public => true)

LessonQuestion.create(:lesson_id => 1, :question_id => 1)
LessonQuestion.create(:lesson_id => 1, :question_id => 4)


#それぞれのクラス
LessonQuestion.create(:lesson_id => 2, :question_id => 1, :start_time => (Date.today - 7).to_s, :end_time => (Date.today + 11).to_s)
LessonQuestion.create(:lesson_id => 2, :question_id => 2, :start_time => (Date.today - 3).to_s, :end_time => (Date.today + 4).to_s)
# LessonQuestion.create(:lesson_id => 2, :question_id => 3, :start_time => (Date.today + 7).to_s, :end_time => (Date.today + 10).to_s)
#
# LessonQuestion.create(:lesson_id => 3, :question_id => 4, :start_time => (Date.today - 3).to_s, :end_time => (Date.today + 4).to_s)

# 問題のkeywordのサンプル
QuestionKeyword.create(:question_id => 1, :keyword => "the 3n+1 problem")
# QuestionKeyword.create(:question_id => 1, :keyword => "solution")
QuestionKeyword.create(:question_id => 2, :keyword => "Financial Management C言語")


# 入出力サンプル
Sample.create(:question_id => 1, :input => "1 10", :output => "1 10 20")
Sample.create(:question_id => 1, :input => "100 200", :output => "100 200 125")
Sample.create(:question_id => 2,
              :input => "100.00 489.12 12454.12 1234.10 823.05 109.20 5.27 1542.25 839.18 83.99 1295.01 1.75",
              :output => "$1581.42")
Sample.create(:question_id => 3, :input => "10", :output => "30")
Sample.create(:question_id => 4, :input => "10", :output => "30")

# テストデータ
TestDatum.create(:question_id => 1, :input => "intest1", :output => "outtest1", :input_storename => "input1", :output_storename => "output1")
TestDatum.create(:question_id => 1, :input => "intest2", :output => "outtest2", :input_storename => "input1", :output_storename => "output1")
TestDatum.create(:question_id => 1, :input => "intest3", :output => "outtest3", :input_storename => "input3", :output_storename => "output3")
TestDatum.create(:question_id => 1, :input => "intest4", :output => "outtest4", :input_storename => "input4", :output_storename => "output4")
TestDatum.create(:question_id => 2, :input => "input_test", :output => "output_test", :input_storename => "input1", :output_storename => "output1")
TestDatum.create(:question_id => 3, :input => "10", :output => "30")
TestDatum.create(:question_id => 3, :input => "2", :output => "6")
TestDatum.create(:question_id => 3, :input => "121", :output => "363")
TestDatum.create(:question_id => 4, :input => "121", :output => "363")


# 回答
# # 学生1
# #Answer.create(:student_id => 7, :lesson_id => 2, :question_id => 1, :file_name => "version2.txt", :language => "c", :result => 1, :plagiarism_percentage => 0.4)
# # Answer.create(:student_id => 7, :lesson_id => 2, :question_id => 1, :file_name => "version2.txt", :language => "c", :result => -1, :plagiarism_percentage => 0.4)
# # Answer.create(:student_id => 7, :lesson_id => 2, :question_id => 1, :file_name => "version3.txt", :language => "c", :result => 1, :run_time => 1, :memory_usage => 10, :plagiarism_percentage => 0.4)
# # Answer.create(:student_id => 7, :lesson_id => 2, :question_id => 1, :file_name => "version4.txt", :language => "c", :result => 1, :run_time => 0.1, :memory_usage => 5, :plagiarism_percentage => 0.9)
#
# Answer.create(:student_id => 7, :lesson_id => 2, :question_id => 2, :file_name => "version2.txt", :language => "c", :result => "A", :run_time => 0.1, :memory_usage => 5,:question_version => 1, :plagiarism_percentage => 0.1)
#
#
# # 学生2
# Answer.create(:student_id => 8, :lesson_id => 2, :question_id => 1, :file_name => "version2.txt", :language => "c", :result => "WA", :question_version => 1, :plagiarism_percentage => 0.1)
# Answer.create(:student_id => 8, :lesson_id => 2, :question_id => 1, :file_name => "version1.c", :language => "c", :result => "A", :run_time => 0.1, :memory_usage => 5, :question_version => 1, :plagiarism_percentage => 0.1)
# # Answer.create(:student_id => 8, :lesson_id => 2, :question_id => 2, :file_name => "version2.txt", :language => "c", :result => "WA",:question_version=> 1, :plagiarism_percentage => 0.2)
# # Answer.create(:student_id => 8, :lesson_id => 2, :question_id => 2, :file_name => "version2.txt", :language => "c", :result => "A", :run_time => 1, :question_version => 1, :memory_usage => 10, :plagiarism_percentage => 0.5)
#
# # クラス1の残りの学生
# (9..14).each do |i|
#   Answer.create(:student_id => i, :lesson_id => 2, :question_id => 1, :file_name => "version2.txt", :language => "c", :result => "A", :run_time => 3, :memory_usage => 50, :question_version => 1, :plagiarism_percentage => 0.3)
# end

# internet check result
# InternetCheckResult.create(:answer_id => 1,
#                            :title => "3n+1 solution c",
#                            :link => "www.google.co.jp",
#                            :content => "You should process all pairs of integers and for each pair determine the maximum cycle length over all integers ",
#                            :repeat => 5)
# InternetCheckResult.create(:answer_id => 1,
#                            :title => "3n+1 solution c",
#                            :link => "www.solution.co.jp",
#                            :content => "all pairs of integers and for each pair determine the maximum cycle length over all integers ",
#                            :repeat => 3)
# InternetCheckResult.create(:answer_id => 2, :title => "blank", :link => "blank", :content => "blank", :repeat => 0)
