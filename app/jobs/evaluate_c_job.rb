# -*- coding: utf-8 -*-
class EvaluateCJob < ActiveJob::Base
  queue_as :evaluate
  include EvaluateProgram

  # Cプログラムの評価実行
  # @param [Fixnum] user_id ユーザID
  # @param [Fixnum] lesson_id 授業ID
  # @param [Fixnum] question_id 問題ID
  def perform(user_id:, lesson_id:, question_id:, lesson_question_id:)
    # 作業ディレクトリ名を乱数で生成
    dir_name = EVALUATE_WORK_DIR.to_s + "/" + Digest::MD5.hexdigest(DateTime.now.to_s + rand.to_s)

    question = Question.find_by(:id => question_id)
    run_time_limit = question.run_time_limit / 1000
    memory_usage_limit = question.memory_usage_limit
    answer = Answer.where(:student_id => user_id,
                          :lesson_id => lesson_id,
                          :question_id => question_id,
                          :lesson_question_id => lesson_question_id).last
    ext = EXT[answer.language]
    test_data = TestDatum.where(:question_id => question_id, :is_deleted => false)
    test_count = test_data.size
    test_data_dir = UPLOADS_QUESTIONS_PATH.join(question_id.to_s)
    # アップロードされたファイル
    original_file = UPLOADS_ANSWERS_PATH.join(user_id.to_s, lesson_question_id.to_s, answer.file_name)
    src_file = "cpp_src#{ext}" # コンパイル前のソースファイル
    exe_file = "cpp_exe" # コンパイル後のソースファイル

    # 作業ディレクトリの作成
    FileUtils.mkdir_p(dir_name) unless FileTest.exist?(dir_name)
    `chmod o+w #{dir_name}`
    # 作業ディレクトリへ移動
    Dir.chdir(dir_name)

    # 作業ディレクトリにプログラムとテストデータをコピー
    FileUtils.copy(original_file, src_file)
    FileUtils.copy(Dir.glob(test_data_dir.to_s + "/*"), ".")

    spec = Hash.new { |h,k| h[k] = {} }
    containers = []

    compile_cmd = "g++ #{src_file} -o #{dir_name}/#{exe_file} -w"
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
      cancel_evaluate(answer, "CE", "#{dir_name}")
      return
    end
    Process.waitpid2(@compile.pid)

    i = 0
    # テストデータの数だけ試行
    begin
      t = Thread.new do
        test_data.each do |test|
          i += 1
          result = "P"
          memory = 0
          time = 0
          spec[i][:result] = result
          spec[i][:memory] = memory
          spec[i][:time] = time

          container_name = Digest::MD5.hexdigest(DateTime.now.to_s + rand.to_s)
          containers.push(container_name)

          # dockerコンテナでプログラムを実行
          # 最大プロセス数: 10
          # 最大実行メモリ(RSS): 256 MB
          # 最大ファイルサイズ: 40 MB
          rss = MEMORY_LIMIT * 1024 * 1000
          test_inputname = test.input_storename
          test_outputname = test.output_storename
          exec_cmd = "docker run --rm -u exec_user --name #{container_name} -e NUM=#{i} -e INPUT=#{test_inputname} -e EXE=#{exe_file} -v #{dir_name}:/home/exec_user/work --ulimit nproc=5 --ulimit rss=#{rss} --ulimit cpu=#{run_time_limit + 1} --ulimit fsize=10240000 -m #{MEMORY_LIMIT}m --net=none -t procs/cpp_sandbox"

          begin
            # 実行時間制限
            Timeout.timeout(TIMEOUT_LIMIT) do
              # 入力用ファイルを入力し，結果をファイル出力
              @exec = IO.popen(exec_cmd)
              Process.waitpid2(@exec.pid)
            end

          rescue Timeout::Error
            `docker kill #{container_name}`
            puts "Kill timeout container #{container_name}"
            puts "Wall-Clock Time Limit Exceeded"
            spec[i][:result] = "TIMEOUT"
            next
          end

          # 結果と出力用ファイルのdiff
          diff = `diff #{test_outputname} result#{i}`

          signal = nil
          # 実行時間とメモリ使用量を記録
          File.open("spec#{i}", "r") do |f|
              first = f.gets
            if first.include?("signal")
              signal = first
              memory = f.gets.to_i
            else
              memory = first.to_i
            end
            utime = f.gets.to_f
            stime = f.gets.to_f
            time = (utime + stime) * 1000
          end

          spec[i][:memory] = memory
          spec[i][:time] = time

          unless signal.nil?
            if signal.include?("11")
              puts "Runtime Error"
              spec[i][:result] = "RE"
              next
            elsif signal.include?("9")
              if time.ceil >= (run_time_limit * 1000)
                puts "Time Limit Exceeded"
                spec[i][:result] = "TLE"
                next
              elsif (memory / 1024) >= memory_usage_limit
                puts "Memory Limit Exceeded"
                spec[i][:result] = "MLE"
                next
              end
            end
          end

          # diff結果が異なればそこでテスト失敗
          unless diff.empty?
            puts "Wrong Answer"
            spec[i][:result] = "WA"
            next
          end

          # どれにも当てはまらなかったらAccept
          spec[i][:result] = "A"
        end
      end
      t.join
    rescue
      pp $!
    end

    # 最大値を求めるためのソート
    results =  spec.inject([]){|prev, (key, val)| prev.push val[:result]}
    times = spec.inject([]){|prev, (key, val)| prev.push val[:time]}
    memories = spec.inject([]){|prev, (key, val)| prev.push val[:memory]}

    # resultを求める
    # 優先度: TERM > TIMEOUT > WA > MLE > TLE > A
    passed = results.count("A")
    if test_count == passed
      res = "A"
    else
      if results.include?("RE")
        res = "RE"
      elsif results.include?("TIMEOUT")
        res = "TIMEOUT"
      elsif results.include?("MLE")
        res = "MLE"
      elsif results.include?("TLE")
        res = "TLE"
      elsif results.include?("WA")
        res = "WA"
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
    `rm -fr #{dir_name}`
    if res == "A"
      # C言語ローカル剽窃チェックスクリプトをメッセージキューに入れる
      LocalCheckCJob.perform_later(:user_id => user_id,
                                   :lesson_id => lesson_id,
                                   :question_id => question_id,
                                   :lesson_question_id => lesson_question_id)
    end
    return
  end
end
