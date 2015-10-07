# -*- coding: utf-8 -*-
module EvaluateProgram
  # 失敗時の処理
  # @param [Answer] answer 保存するAnswerオブジェクト
  # @param [String] result resultに記録する文字列
  # @param [String] dirname 作業ディレクトリ
  def cancel_evaluate(answer, result, dirname)
    answer.result = result
    answer.save
    `rm -r #{dirname}`
    return
  end


end
