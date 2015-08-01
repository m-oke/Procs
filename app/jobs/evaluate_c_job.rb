# -*- coding: utf-8 -*-
class EvaluateCJob < ActiveJob::Base
  queue_as :evaluate
  include EvaluateProgram

  # Cプログラムの評価実行
  # @param [Fixnum] user_id ユーザID
  # @param [Fixnum] lesson_id 授業ID
  # @param [Fixnum] question_id 問題ID
  def perform(user_id:, lesson_id:, question_id:)
    # ファイル名やファイル場所の設定
    work_filename = "#{user_id}_#{lesson_id}_#{question_id}" # 作業用ファイル名接頭辞
    work_dir_file = EVALUATE_WORK_DIR.join(work_filename) # 接頭辞
    spec_file = "#{work_dir_file}_spec" # 実行時間とメモリ使用量記述ファイル

    question = Question.find_by(:id => question_id)
    run_time_limit = question.run_time_limit || 5 # 実行時間が未設定ならば5秒
    memory_usage_limit = question.memory_usage_limit || 256 # メモリ使用量が未設定ならば256MB
    answer = Answer.where(:student_id => user_id,
                          :lesson_id => lesson_id,
                          :question_id => question_id).last
    ext = EXT[answer.language]
    test_data = TestDatum.where(:question_id => question_id)
    test_count = test_data.size
    test_data_dir = UPLOADS_QUESTIONS_PATH.join(question_id.to_s)
    original_file = UPLOADS_ANSWERS_PATH.join(user_id.to_s, lesson_id.to_s, question_id.to_s, answer.file_name) # アップロードされたファイル
    src_file = "#{work_dir_file}_src#{ext}" # コンパイル前のソースファイル
    exe_file = "#{work_dir_file}_exe" # コンパイル前のソースファイル

    FileUtils.mkdir_p(EVALUATE_WORK_DIR) unless FileTest.exist?(EVALUATE_WORK_DIR)
    FileUtils.copy(original_file, src_file)

    Dir.chdir(EVALUATE_WORK_DIR)
    spec = Hash.new { |h,k| h[k] = {} }

    compile_cmd = "gcc #{src_file} -o #{exe_file} -w"
    # コンパイル
    @compile = IO.popen(compile_cmd, :err => [:child, :out])

    # コンパイラの出力取得
    compile_error = ""
    while line = @compile.gets
      compile_error += line
    end

    # コンパイルエラー時
    unless compile_error.empty?
      puts "Complilation Error"
      cancel_evaluate(answer, "CE", "#{work_dir_file}")
      return
    end
    Process.waitpid2(@compile.pid)

    # テストデータの数だけ試行
    1.upto(test_count) do |i|
      exec_cmd = "ts=$(date +%s%N); (/usr/bin/time -f '%M' #{exe_file} < #{test_data_dir}/input#{i} > #{work_dir_file}_result#{i}) 2> #{spec_file}; tt=$((($(date +%s%N) - $ts)/1000000)); echo $tt >> #{spec_file}"

      begin
        # 実行時間制限
        Timeout.timeout(run_time_limit) do
          # 入力用ファイルを入力し，結果をファイル出力
          @exec = IO.popen(exec_cmd)
          Process.waitpid2(@exec.pid)
        end

      rescue Timeout::Error
        # 複数のプロセスを実行するため pid + 3
        Process.kill(:KILL, @exec.pid + 3)
        puts "Kill timeout process #{@exec.pid + 3}"
        puts "Time Limit Exceeded"
        cancel_evaluate(answer, "TLE", "#{work_dir_file}")
        return
      end

      # 結果と出力用ファイルのdiff
      result = `diff #{test_data_dir}/output#{i} #{work_filename}_result#{i}`

      # diff結果が異なればそこでテスト失敗
      unless result.empty?
        puts "Wrong Answer"
        cancel_evaluate(answer, "WA", "#{work_dir_file}")
        return
      end

      # 実行時間とメモリ使用量を記録
      memory = 0
      time = 0
      File.open(spec_file, "r") do |f|
        memory = f.gets.to_i
        time = f.gets.to_i
      end

      if (memory / 1024) > memory_usage_limit
        puts "Memory Limit Exceeded"
        cancel_evaluate(answer, "MLE", "#{work_dir_file}")
        return
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
    `rm #{work_dir_file}*`
    return
  end
end
