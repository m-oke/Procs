# -*- coding: utf-8 -*-
class EvaluatePythonJob < ActiveJob::Base
  queue_as :evaluate
  include EvaluateProgram
  EVAL_ENV = "docker" # 検証用の環境変数

  # pythonプログラムの評価実行
  # @param [Fixnum] user_id ユーザID
  # @param [Fixnum] lesson_id 授業ID
  # @param [Fixnum] question_id 問題ID
  def perform(user_id:, lesson_id:, question_id:)
    # 作業ディレクトリ名を乱数で生成
    dir_name = EVALUATE_WORK_DIR.to_s + "/" + Digest::MD5.hexdigest(DateTime.now.to_s + rand.to_s)

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

    exe_file = "python#{ext}" # 追記後の実行ファイル

    # 作業ディレクトリの作成
    FileUtils.mkdir_p(dir_name) unless FileTest.exist?(dir_name)
    # 作業ディレクトリへ移動
    Dir.chdir(dir_name)

    # 作業ディレクトリにプログラムとテストデータをコピー
    FileUtils.copy(original_file, exe_file)
    FileUtils.copy(Dir.glob(test_data_dir.to_s + "/*"), ".")

    spec = Hash.new { |h,k| h[k] = {} }
    containers = []

    # テストデータの数だけ繰り返し
    1.upto(test_count) do |i|
      result = "P"
      memory = 0
      time = 0
      spec[i][:result] = result
      spec[i][:memory] = memory
      spec[i][:time] = time

      # コンテナ名を乱数のハッシュで生成
      container_name = Digest::MD5.hexdigest(DateTime.now.to_s + rand.to_s)
      containers.push(container_name)
      # dockerコンテナでプログラムを実行
      exec_cmd = "docker run --name #{container_name} -e NUM=#{i} -e EXE=#{exe_file} -v #{dir_name}:/home/test_user/work errorcode/python_sandbox"

      begin
        # 実行時間制限
        Timeout.timeout(run_time_limit) do
          # 入力用ファイルを入力し，結果をファイル出力
          @exec = IO.popen(exec_cmd)
          Process.waitpid2(@exec.pid)
        end

        # 処理中にタイムアウトになった場合
      rescue Timeout::Error
        `docker kill #{container_name}`
        puts "Kill timeout container #{container_name}"
        puts "Time Limit Exceeded"
        spec[i][:result] = "TLE"
        next
      end

      # 結果と出力用ファイルのdiff
      diff = `diff output#{i} result#{i}`

      # diff結果が異なればそこでテスト失敗
      unless diff.empty?
        puts "Wrong Answer"
        spec[i][:result] = "WA"
        next
      end

      # 実行時間とメモリ使用量を記録
      File.open("spec#{i}", "r") do |f|
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
    # 優先度: WA > MLE > TLE > A
    passed = 0
    res = "A"
    results.each do |result|
      case result
      when "A"
        passed += 1
      when "WA"
        res = result
      when "MLE"
        res = result if res != "WA"
      when "TLE"
        res = result if res != "WA" && res != "MLE"
      end
    end

    # 実行結果を記録
    answer.result = res
    answer.run_time = times.max
    answer.memory_usage = memories.max
    answer.test_passed = passed
    answer.test_count = test_count
    answer.save

    # コンテナの削除
    containers.each {|c| `docker rm #{c}`}

    # 作業ディレクトリの削除
    Dir.chdir("..")
    `rm -r #{dir_name}`
    return
  end
end
