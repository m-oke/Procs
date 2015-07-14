# -*- coding: utf-8 -*-
class EvaluatePythonJob < ActiveJob::Base
  queue_as :default

  def perform(user_id:, lesson_id:, question_id:)
    root_dir = Rails.root.to_s
    file_dir = "#{root_dir}/uploads/#{user_id}/#{lesson_id}/#{question_id}"
    tmp_dir = "#{root_dir}/tmp/answers"
    tmp_filename = "#{user_id}_#{lesson_id}_#{question_id}"

    answer = Answer.where(:student_id => user_id,
                          :lesson_id => lesson_id,
                          :question_id => question_id).last
    file = "#{file_dir}/#{answer.file_name}"
    test_data = TestDatum.where(:question_id => question_id)
    test_count = test_data.size
    FileUtils.mkdir_p(tmp_dir) unless FileTest.exist?(tmp_dir)

    test_data.each.with_index(1) do |data,i|
      File.open("#{tmp_dir}/#{tmp_filename}_input#{i}", "w+"){ |f| f.write(data.input) }
      # python実行結果と形式を一緒にするために末尾に改行を追加
      File.open("#{tmp_dir}/#{tmp_filename}_output#{i}", "w+") do |f|
        f.write(data.output)
        f.write("\n")
      end
    end

    Dir.chdir(tmp_dir)
    test_count.times do |i|
      `python3 #{file} < #{tmp_dir}/#{tmp_filename}_input#{i + 1} > #{tmp_dir}/#{tmp_filename}_result#{i + 1}`
      result = `diff #{tmp_filename}_output#{i + 1} #{tmp_filename}_result#{i + 1}`
      unless result.empty?
        answer.result = -1
        answer.save
        `rm #{tmp_dir}/#{tmp_filename}*`
        return
      end
    end
    answer.result = 1
    answer.save
    `rm #{tmp_dir}/#{tmp_filename}*`
    return
  end
end
