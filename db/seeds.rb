# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# 管理者
User.create(:id_number => "201510000", :name => "管理者1", :faculty => "研究科1", :department => "工学域1", :grade => 0, :role => 0, :admin => true, :email => "Admin1@user.com", :password => "testtest")

# 教師
3.times do |i|
    User.create(:id_number => "20151000#{i + 1}", :name => "教員#{i + 1}", :faculty => "工学域#{i + 1}", :department => "工学域#{i + 1}", :grade => 0, :role => 0, :admin => false, :email => "faculty#{i + 1}@user.com", :password => "testtest")
end

# 学生
20.times do |i|
  User.create(:id_number => "20152000#{i + 1}", :name => "学生#{i + 1}", :faculty => "学部#{(i + 1) % 3 + 1}", :department => "学科#{(i + 1) % 2 + 1}", :grade => ((i + 1) % 4), :role => 1, :admin => false, :email => "student#{i + 1}@user.com", :password => "testtest")
end

# クラス
2.times do |i|
  Lesson.create(:name => "講義#{i + 1}", :description => "説明#{i + 1}", :term => "学期#{i + 1}", :date => i + 1, :period => "#{i + 2},#{i + 3}")
end

# ユーザ:クラス
# 教師
2.times do |i|
  UserLesson.create(:id_number => "20151000#{i + 1}", :lesson_id => i + 1)
end

# 学生
15.times do |i|
  UserLesson.create(:id_number => "20152000#{i + 1}", :lesson_id => ((i) % 2 + 1))
end

# 問題
# 過去の問題
Question.create(:title => "問題1", :lesson_id => 1, :content => "問題1の内容", :start_time => (Date.today - 7).to_s, :end_time => (Date.today - 1).to_s, :input_description => "問題1の入力説明", :output_description => "問題1の出力説明",  :run_time_limit => 5, :memory_usage_limit => 256, :cpu_usage_limit => 50)

# 現在の問題
Question.create(:title => "問題2", :lesson_id => 1, :content => "問題2の内容", :start_time => (Date.today - 3).to_s, :end_time => (Date.today + 4).to_s, :input_description => "問題2の入力説明", :output_description => "問題2の出力説明",  :run_time_limit => 5, :memory_usage_limit => 256, :cpu_usage_limit => 50)

# 未来の問題
Question.create(:title => "問題3", :lesson_id => 1, :content => "問題3の内容", :start_time => (Date.today + 7).to_s, :end_time => (Date.today + 10).to_s, :input_description => "問題3の入力説明", :output_description => "問題3の出力説明",  :run_time_limit => 5, :memory_usage_limit => 256, :cpu_usage_limit => 50)

# 入出力サンプル
Sample.create(:question_id => 1, :input => "1 2 3", :output => "6")
Sample.create(:question_id => 1, :input => "2 3 4", :output => "9")
Sample.create(:question_id => 2, :input => "2", :output => "1")
Sample.create(:question_id => 2, :input => "5", :output => "1")
Sample.create(:question_id => 3, :input => "10", :output => "30")

# テストデータ
TestDatum.create(:question_id => 1, :input => "1 2 3", :output => "6")
TestDatum.create(:question_id => 1, :input => "2 3 4", :output => "9")
TestDatum.create(:question_id => 1, :input => "10 50 100", :output => "160")
TestDatum.create(:question_id => 2, :input => "2", :output => "1")
TestDatum.create(:question_id => 2, :input => "5", :output => "1")
TestDatum.create(:question_id => 2, :input => "100", :output => "1")
TestDatum.create(:question_id => 3, :input => "10", :output => "30")
TestDatum.create(:question_id => 3, :input => "2", :output => "6")
TestDatum.create(:question_id => 3, :input => "121", :output => "363")


# 回答
# 学生1
Answer.create(:student_id_number => "201520001", :question_id => 1, :file_name => "version1.txt", :language => "c", :result => 0, :plagiarism_percentage => 0.4)
Answer.create(:student_id_number => "201520001", :question_id => 1, :file_name => "version2.txt", :language => "c", :result => 0, :plagiarism_percentage => 0.4)
Answer.create(:student_id_number => "201520001", :question_id => 1, :file_name => "version3.txt", :language => "c", :result => 1, :run_time => 1, :memory_usage => 10, :cpu_usage => 10, :plagiarism_percentage => 0.4)
Answer.create(:student_id_number => "201520001", :question_id => 1, :file_name => "version4.txt", :language => "c", :result => 1, :run_time => 0.1, :memory_usage => 5, :cpu_usage => 10, :plagiarism_percentage => 0.9)

Answer.create(:student_id_number => "201520001", :question_id => 2, :file_name => "version1.txt", :language => "c", :result => 1, :run_time => 0.1, :memory_usage => 5, :cpu_usage => 10, :plagiarism_percentage => 0.1)


# 学生3
Answer.create(:student_id_number => "201520003", :question_id => 1, :file_name => "version1.txt", :language => "c", :result => 0, :plagiarism_percentage => 0.1)

Answer.create(:student_id_number => "201520003", :question_id => 2, :file_name => "version1.txt", :language => "c", :result => 0, :plagiarism_percentage => 0.2)
Answer.create(:student_id_number => "201520003", :question_id => 2, :file_name => "version2.txt", :language => "c", :result => 1, :run_time => 1, :memory_usage => 10, :cpu_usage => 10, :plagiarism_percentage => 0.5)

# 残りの学生
(5..15).each do |i|
  if i % 2 == 1
    Answer.create(:student_id_number => "20152000#{i}", :question_id => 1, :file_name => "version1.txt", :language => "c", :result => 1, :run_time => 3, :memory_usage => 50, :cpu_usage => 10, :plagiarism_percentage => 0.3)
  end
end
