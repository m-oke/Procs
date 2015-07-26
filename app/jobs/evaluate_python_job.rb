# -*- coding: utf-8 -*-
class EvaluatePythonJob < ActiveJob::Base
  queue_as :evaluate
  include EvaluateProgram

  # pythonプログラムの評価実行
  # @param [Fixnum] user_id ユーザID
  # @param [Fixnum] lesson_id 授業ID
  # @param [Fixnum] question_id 問題ID
  def perform(user_id:, lesson_id:, question_id:)
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
    FileUtils.copy(original_file, exe_file)

    # テストデータをファイル出力
    test_data.each.with_index(1) do |data,i|
      # 入力用ファイル
      File.open("#{work_dir}/#{work_filename}_input#{i}", "w+"){ |f| f.write(data.input) }
      # 出力用ファイル
      # python実行結果と形式を一緒にするために末尾に改行を追加
      File.open("#{work_dir}/#{work_filename}_output#{i}", "w+"){ |f| f.puts(data.output) }
    end

    Dir.chdir(work_dir)
    spec = Hash.new { |h,k| h[k] = {} }

    # テストデータの数だけ繰り返し
    1.upto(test_count) do |i|
      exec_cmd = "ts=$(date +%s%N); (/usr/bin/time -f '%M' python3 #{exe_file} < #{work_dir}/#{work_filename}_input#{i} > #{work_dir}/#{work_filename}_result#{i}) 2> #{spec_file}; tt=$((($(date +%s%N) - $ts)/1000000)); echo $tt >> #{spec_file}"

      begin
        Timeout.timeout(run_time_limit) do
          # 入力用ファイルを入力し，結果をファイル出力
          @process = IO.popen(exec_cmd)
          Process.waitpid2(@process.pid)
        end

        # 処理中にタイムアウトになった場合
      rescue Timeout::Error => e
        # Rubyのプロセス管理の理由からpid + 1
        Process.kill(:KILL, @process.pid + 3)
        puts "kill timeout process #{@process.pid + 3}"
        cancel_evaluate(answer, "TO", "#{work_dir}/#{work_filename}")
        return
      end

      # 結果と出力用ファイルのdiff
      result = `diff #{work_filename}_output#{i} #{work_filename}_result#{i}`

      # diff結果が異なればそこでテスト失敗
      unless result.empty?
        cancel_evaluate(answer, "WA", "#{work_dir}/#{work_filename}")
        return
      end

      # 実行時間とメモリ使用量を記録
      memory = 0
      time = 0
      File.open(spec_file, "r") do |f|
        memory = f.gets
        time = f.gets
      end
      spec[i][:memory] = memory
      spec[i][:time] = time
    end

    # 最大値を求めるためのソート
    times = spec.inject([]){|prev, (key, val)| prev.push val[:time]}
    memories = spec.inject([]){|prev, (key, val)| prev.push val[:memory]}

    # 実行結果を記録
    answer.result = "A"
    answer.run_time = times.max
    answer.memory_usage = memories.max
    answer.save
    `rm #{work_dir}/#{work_filename}*`
    return
  end
end
