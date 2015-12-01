class LocalCheckCJob < ActiveJob::Base
  queue_as :plagiarism

  def perform(user_id:, lesson_id:, question_id:)
    # ローカル剽窃チェックテスト

    answer = Answer.where(:student_id => user_id,
                          :lesson_id => lesson_id,
                          :question_id => question_id).last
    @target_file = UPLOADS_ANSWERS_PATH.join(user_id.to_s, lesson_id.to_s, question_id.to_s, answer.file_name)
    @compare_file = UPLOADS_ANSWERS_PATH.join(user_id.to_s, lesson_id.to_s, question_id.to_s, answer.file_name)
    @target_name = answer.file_name
    @target_path = @target_file.to_s
    @compare_name = answer.file_name
    @compare_path = @compare_file.to_s

    @target_line = ""
    @compare_line = ""
    @check_token = 0

    @c_check = local_check_c
    p @c_check
    #open( 'exammm.txt' ,'w+' ).write( open( 'test.txt' ).readlines.join.sub( /\d+/m ,'' ) )
    #open( 'exannn.txt' ,'w+' ).write( open( 'test.txt' ).readlines.join.sub( /\[\d+\]/m ,'' ) )
    @c_check.each_with_index do |line,i|
      if i == 0
        # Take the target file s token in first line
        target_token_left = line.rindex(@target_name + ":") + @target_name.size + 1
        target_token_right = line.rindex("tokens") - 1
        @target_token = line.strip[target_token_left..target_token_right]
      end
      if line.include?("|" + @compare_path )
        # Take the line No. in target file which is checked
        target_line_left = @target_path.size + 7
        target_line_right = line.rindex("|" + @compare_path ) - 1
        @target_line << line.strip[target_line_left..target_line_right] + ";"

        # Take the line No. in compare file which is checked
        compare_line_left = line.rindex(@compare_path) + @compare_path.size + 7
        compare_line_right = line.rindex("[") - 1
        @compare_line << line.strip[compare_line_left..compare_line_right] + ";"

        # Take the token be checked with target file and compare file
        check_token_left = line.rindex("[") + 1
        check_token_right = line.rindex("]") - 1
        @check_token += line[check_token_left..check_token_right].to_i
      end
    end
    # [目標ファイルtoken数,比較ファイル名,目標類似行,類似token数]の配列を作る
    @local_result = Array.new(0,Array.new(5,0)) #[] [[0,0,0,0,0]]
    @local_result.push([@target_token,@compare_path,@target_line,@compare_line,@check_token])
    # SORT
    @local_result = @local_result.sort do |item1,item2|
      item2[5]<=> item1[5]
    end
    result_temp = LocalCheckResult.new(:answer_id => answer.id, :check_result => (@check_token.to_f/@target_token.to_f*100) , :check_file => (@compare_path), :target_line => @target_line, :compare_line => @compare_line )
    result_temp.save

  end

  # チェックの実行とファイルの表示
  def local_check_c
    `sim_c #{@target_file} / #{@compare_file} > #{UPLOADS_ANSWERS_PATH}/localcheck/test.txt`
    check = File.open(UPLOADS_ANSWERS_PATH.to_s + '/localcheck/test.txt', 'r:utf-8')
    return check
  end
end
