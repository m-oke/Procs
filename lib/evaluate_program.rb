# -*- coding: utf-8 -*-
module EvaluateProgram
  # 失敗時の処理
  # @param [Answer] answer 保存するAnswerオブジェクト
  # @param [String] result resultに記録する文字列
  # @param [String] filename 一時保存のファイル名
  def cancel_evaluate(answer, result, filename)
    answer.result = result
    answer.save
    `rm #{filename}*`
    return
  end


end
