# -*- coding: utf-8 -*-
class EvaluateCJob < ActiveJob::Base
  queue_as :evaluate

  def perform(*args)
    # ファイル名やファイル場所の設定
    root_dir = Rails.root.to_s
    work_dir = "#{root_dir}/tmp/answers" # 作業ディレクトリ
    work_filename = "#{user_id}_#{lesson_id}_#{question_id}" # 作業用ファイル名接頭辞
    spec_file = "#{work_dir}/#{work_filename}_spec" # 実行時間とメモリ使用量記述ファイル

    question = Question.find_by(:id => question_id)
    run_time_limit = question.run_time_limit || 5 # 実行時間が未設定ならば5秒
    answer = Answer.where(:student_id => user_id,
                          :lesson_id => lesson_id,
                          :question_id => question_id).last
    ext = EXT[answer.language]
    test_data = TestDatum.where(:question_id => question_id)
    test_count = test_data.size
    original_file = "#{root_dir}/uploads/#{user_id}/#{lesson_id}/#{question_id}/#{answer.file_name}" # アップロードされたファイル
    exe_file = "#{work_dir}/#{work_filename}_exe#{ext}" # 追記後の実行ファイル

    FileUtils.mkdir_p(work_dir) unless FileTest.exist?(work_dir)

    # テストデータをファイル出力
    test_data.each.with_index(1) do |data,i|
      # 入力用ファイル
      File.open("#{work_dir}/#{work_filename}_input#{i}", "w+"){ |f| f.write(data.input) }
      # 出力用ファイル
      # 実行結果と形式を一緒にするために末尾に改行を追加
      File.open("#{work_dir}/#{work_filename}_output#{i}", "w+"){ |f| f.puts(data.output) }
    end


  end
end
