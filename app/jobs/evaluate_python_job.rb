# -*- coding: utf-8 -*-
class EvaluatePythonJob < ActiveJob::Base
  queue_as :evaluate

  def perform(user_id:, lesson_id:, question_id:)
    root_dir = Rails.root.to_s
    file_dir = "#{root_dir}/uploads/#{user_id}/#{lesson_id}/#{question_id}"
    tmp_dir = "#{root_dir}/tmp/answers"
    tmp_filename = "#{user_id}_#{lesson_id}_#{question_id}"
    time_file = "#{tmp_dir}/time"

    answer = Answer.where(:student_id => user_id,
                          :lesson_id => lesson_id,
                          :question_id => question_id).last
    test_data = TestDatum.where(:question_id => question_id)
    test_count = test_data.size
    FileUtils.mkdir_p(tmp_dir) unless FileTest.exist?(tmp_dir)

    test_data.each.with_index(1) do |data,i|
      File.open("#{tmp_dir}/#{tmp_filename}_input#{i}", "w+"){ |f| f.write(data.input) }
      # python実行結果と形式を一緒にするために末尾に改行を追加
      File.open("#{tmp_dir}/#{tmp_filename}_output#{i}", "w+") do |f|
        f.puts(data.output)
      end
    end
    original_file = "#{file_dir}/#{answer.file_name}"
    exe_file = "#{tmp_dir}/#{tmp_filename}_exe.py"
    File.open(exe_file, "w+") do |exe|
      exe.puts('import time')
      exe.puts('start = time.time()')
      exe.puts("#{File.open(original_file, "r").read}")
      exe.puts('elapse = time.time() - start')
      exe.puts("f = open('#{time_file}', 'w+', encoding='UTF-8')")
      exe.puts('f.write(str(elapse))')
      exe.puts('f.close()')
    end

    Dir.chdir(tmp_dir)
    spec = Hash.new { |h,k| h[k] = {} }
    1.upto(test_count) do |i|
      `python3 #{exe_file} < #{tmp_dir}/#{tmp_filename}_input#{i} > #{tmp_dir}/#{tmp_filename}_result#{i}`
      result = `diff #{tmp_filename}_output#{i} #{tmp_filename}_result#{i}`

      unless result.empty?
        answer.result = -1
        answer.save
        `rm #{tmp_dir}/#{tmp_filename}*`
        return
      end

      time = 0
      File.open(time_file, "r"){|f| time = f.gets}
      spec[i][:time] = time
    end
    times = spec.inject([]){|prev, (key, val)| prev.push val[:time]}

    answer.result = 1
    answer.run_time = times.max
    answer.save
    logger.info(spec)
#    `rm #{tmp_dir}/#{tmp_filename}*`
    return
  end
end
