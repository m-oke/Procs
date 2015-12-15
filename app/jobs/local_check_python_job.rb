class LocalCheckPythonJob < ActiveJob::Base
  queue_as :plagiarism

  def perform(user_id:, lesson_id:, question_id:, lesson_question_id:)
    answer = Answer.where(:student_id => user_id,
                          :lesson_id => lesson_id,
                          :question_id => question_id,
                          :lesson_question_id => lesson_question_id).last
    @target_dir = UPLOADS_ANSWERS_PATH.join(user_id.to_s, lesson_question_id.to_s).to_s
    @target_file = UPLOADS_ANSWERS_PATH.join(user_id.to_s, lesson_question_id.to_s, answer.file_name)
    @target_name = answer.file_name
    @target_path = @target_file.to_s
    @lesson = Lesson.find_by(:id => lesson_id)
    check_count = 0
    local_result = []

    # check実行中はlocal_plagiarism_percentageを実行中に表示する
    answer.local_plagiarism_percentage = -1.0
    answer.save

    lesson_questions = LessonQuestion.where(:question_id => question_id)
    lesson_questions.each do |lesson_question|
      @lesson = Lesson.find_by(:id => lesson_question.lesson_id)

      students = User.where(:id => @lesson.user_lessons.where(:is_teacher => false).pluck(:user_id))
      students.each do |s|
        unless s.id == user_id
          compare_answer = Answer.accept_answer(:student_id => s.id,
                                                :question_id => question_id,
                                                :lesson_id => lesson_question.lesson_id,
                                                :lesson_question_id => lesson_question.id)
          if compare_answer.present?

            @compare_file = UPLOADS_ANSWERS_PATH.join(s.id.to_s, lesson_question.id.to_s, compare_answer.file_name)
            @compare_name = compare_answer.file_name
            @compare_path = @compare_file.to_s
            @target_line = ""
            @compare_line = ""
            @check_line = 0
            @plagiarism_percentage = 0.0


            # 類似度検出
            @python_check = local_check_python(@target_file, @compare_file , user_id.to_s, s.id.to_s)
            @python_check.each_with_index do |line,i|
              if line.include?(" lines are duplicates (")
                percentage_left = line.rindex("(") + 1
                percentage_right = line.rindex(")") - 2
                @plagiarism_percentage = line[percentage_left..percentage_right].to_f
              end
            end
            # 生成したファイルを削除
            # File.delete(@target_dir + "/" + user_id.to_s + "_" + s.id.to_s + "_local_py.txt")

            # 類似ファイルとの比較
            @python_check_code = local_check_python_code(@target_file, @compare_file , user_id.to_s, s.id.to_s)
            @python_check_code.each_with_index do |line,i|
              if line.include?( "<duplication lines=" )
                # Take the count of check line
                check_line_right = line.rindex(" tokens=") - 2
                @check_line = line[20..check_line_right].to_i

                check_count += 1
              end
              if line.include?(" path=\"" + @target_path)
                # Take the line No. in target file which is checked
                target_line_right = line.rindex(" path=\"" + @target_path) - 2
                target_line_first_temp = line[12..target_line_right]
                target_line_first = target_line_first_temp.to_i

                # マークラインに空行とコメント行を追加
                tar_check_line = @check_line
                tar_file = File.open(@target_path, 'r:utf-8' )
                k = 0
                flag = false
                tar_file.each_with_index do |l, j|
                  k += 1
                  if j == target_line_first
                    flag = true
                  end
                  if k == tar_check_line
                    break
                  end
                  if flag
                    if l.strip.chars[0].nil? || l.strip.chars[0] == "#"
                      tar_check_line += 1
                    end
                  end
                end
                @target_line << target_line_first.to_s + "-" + (target_line_first + tar_check_line).to_s + ";"
              end
              if line.include?(" path=\"" + @compare_path)
                # Take the line No. in compare file which is checked
                compare_line_right = line.rindex(" path=\"" + @compare_path) - 2
                compare_line_first_temp = line[12..compare_line_right]
                compare_line_first = compare_line_first_temp.to_i

                # マークラインに空行とコメント行を追加
                com_check_line = @check_line
                com_file = File.open(@compare_path, 'r:utf-8' )
                k = 0
                flag = false
                com_file.each_with_index do |l, j|
                  k += 1
                  if j == compare_line_first
                    flag = true
                  end
                  if k == com_check_line
                    break
                  end
                  if flag
                    if l.strip.chars[0].nil? || l.strip.chars[0] == "#"
                      com_check_line += 1
                    end
                  end
                end
                @compare_line << compare_line_first.to_s + "-" + (compare_line_first + com_check_line).to_s + ";"
              end

            end
            # チェック実行で生成したファイルを削除
            # File.delete(@target_dir + "/" + user_id.to_s + "_" + s.id.to_s + "_local_py_code.txt")

            # [比較ファイル名,目標類似行,比較類似行,類似度]の配列を作る
            if check_count == 0
              answer.local_plagiarism_percentage = 0.0
              answer.save
              return
            else
              local_result.push([@target_name,@compare_name,@target_line,@compare_line,@plagiarism_percentage,@compare_path,s.id,compare_answer.lesson_question_id])
              # SORT
              local_result = local_result.sort do |item1,item2|
                item2[4]<=> item1[4]
              end
            end
          end
        end
      end
    end
    if local_result.empty?
      answer.local_plagiarism_percentage = 0.0
      answer.save
      return
    end
    result_temp = LocalCheckResult.new(:answer_id => answer.id,
                                       :check_result => local_result[0][4],
                                       :target_name => local_result[0][0],
                                       :compare_name => local_result[0][1],
                                       :target_line => local_result[0][2],
                                       :compare_line => local_result[0][3],
                                       :compare_path => local_result[0][5],
                                       :compare_user_id => local_result[0][6],
                                       :compare_lesson_question_id => local_result[0][7])
    result_temp.save

    # アンサーの類似度を保存
    answer.local_plagiarism_percentage = local_result[0][4]
    answer.save

  end

  # チェック類似度の表示
  def local_check_python(target_file, compare_file, target_id, compare_id)
    Dir.chdir(UPLOADS_ANSWERS_PATH)
    `clonedigger #{target_file} #{compare_file} --dont-print-time -o #{target_id}_#{compare_id}_local_py.txt`
    sleep(1) until File.exist?(UPLOADS_ANSWERS_PATH.to_s + '/' + target_id + '_' + compare_id + '_local_py.txt')
    check = File.open(UPLOADS_ANSWERS_PATH.to_s + '/' + target_id + '_' + compare_id + '_local_py.txt', 'r:utf-8')
    return check
  end
  # チェックの実行とファイルの表示
  def local_check_python_code(target_file, compare_file, target_id, compare_id)
    Dir.chdir(UPLOADS_ANSWERS_PATH)
    `clonedigger #{target_file} #{compare_file} --dont-print-time --cpd-output -o #{target_id}_#{compare_id}_local_py_code.txt`
    sleep(1) until File.exist?(UPLOADS_ANSWERS_PATH.to_s + '/' + target_id + '_' + compare_id + '_local_py_code.txt')
    check = File.open(UPLOADS_ANSWERS_PATH.to_s + '/' + target_id + '_' + compare_id + '_local_py_code.txt', 'r:utf-8')
    return check
  end
end
