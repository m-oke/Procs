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
    work_filename = "#{user_id}_#{lesson_id}_#{question_id}" # 作業用ファイル名接頭辞
    work_dir_file = EVALUATE_WORK_DIR.join(work_filename) # 接頭辞
    spec_file = "#{work_dir_file}_spec" # 実行時間とメモリ使用量記述ファイル

    question = Question.find_by(:id => question_id)
    run_time_limit = question.run_time_limit.to_f / 1000
    memory_usage_limit = question.memory_usage_limit
    answer = Answer.where(:student_id => user_id,
                          :lesson_id => lesson_id,
                          :question_id => question_id).last
    ext = EXT[answer.language]
    test_data = TestDatum.where(:question_id => question_id)
    test_count = test_data.size
    test_data_dir = UPLOADS_QUESTIONS_PATH.join(question_id.to_s)
    # アップロードされたファイル
    original_file = UPLOADS_ANSWERS_PATH.join(user_id.to_s, lesson_id.to_s, question_id.to_s, answer.file_name)

    exe_file = "#{work_dir_file}_exe#{ext}" # 追記後の実行ファイル

    FileUtils.mkdir_p(EVALUATE_WORK_DIR) unless FileTest.exist?(EVALUATE_WORK_DIR)
    FileUtils.copy(original_file, exe_file)

    Dir.chdir(EVALUATE_WORK_DIR)
    spec = Hash.new { |h,k| h[k] = {} }

    # テストデータの数だけ繰り返し
    1.upto(test_count) do |i|
      result = "P"
      memory = 0
      time = 0
      spec[i][:result] = result
      spec[i][:memory] = memory
      spec[i][:time] = time

      exec_cmd = "ts=$(date +%s%N); (/usr/bin/time -f '%M' python3 #{exe_file} < #{test_data_dir}/input#{i} > #{work_dir_file}_result#{i}) 2> #{spec_file}; tt=$((($(date +%s%N) - $ts)/1000000)); echo $tt >> #{spec_file}"

      begin
        # 実行時間制限
        Timeout.timeout(run_time_limit) do
          # 入力用ファイルを入力し，結果をファイル出力
          @exec = IO.popen(exec_cmd)
          Process.waitpid2(@exec.pid)
        end

        # 処理中にタイムアウトになった場合
      rescue Timeout::Error
        # 複数のプロセスを実行するため pid + 3
        Process.kill(:KILL, @exec.pid + 3)
        puts "Kill timeout process #{@exec.pid + 3}"
        puts "Time Limit Exceeded"
        spec[i][:result] = "TLE"
        next
      end

      # 結果と出力用ファイルのdiff
      diff = `diff #{test_data_dir}/output#{i} #{work_filename}_result#{i}`

      # diff結果が異なればそこでテスト失敗
      unless diff.empty?
        puts "Wrong Answer"
        spec[i][:result] = "WA"
        next
      end

      # 実行時間とメモリ使用量を記録
      File.open(spec_file, "r") do |f|
        memory = f.gets.to_i
        time = f.gets.to_i
      end

      if (memory / 1024) > memory_usage_limit
        puts "Memory Limit Exceeded"
        spec[i][:result] = "MLE"
        next
      end

      spec[i][:result] = "A"
      spec[i][:memory] = memory
      spec[i][:time] = time
    end

    # 最大値を求めるためのソート
    results =  spec.inject([]){|prev, (key, val)| prev.push val[:result]}
    times = spec.inject([]){|prev, (key, val)| prev.push val[:time]}
    memories = spec.inject([]){|prev, (key, val)| prev.push val[:memory]}

    # resultを求める
    passed = 0
    res = "A"
    results.each do |result|
      case result
      when "A"
        passed += 1
      when "WA" || ("MLE" && (res != "WA")) || ("TLE" && (res != "WA" || res != "MLE"))
        res = result
      end
    end

    # 実行結果を記録
    answer.result = res
    answer.run_time = times.max
    answer.memory_usage = memories.max
    answer.test_passed = passed
    answer.test_count = test_count
    answer.save
    `rm #{work_dir_file}*`
    return
  end
end
