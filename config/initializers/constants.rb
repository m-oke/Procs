# -*- coding: utf-8 -*-
LANGUAGES = ["Python", "C"] # 解答可能な言語
EXT = {"c" => ".c", "python" => ".py"} # 対応する拡張子
RESULT = {"MLE" => "Memory Limit Exceeded", "CE" => "Compilation Error", "TLE" => "Time Limit Exceeded", "WA" => "Wrong Answer", "P" => "Pending", "A" => "Accept"} # 評価結果
UPLOADS_PATH = Rails.root.join('uploads') # ファイルアップロードディレクトリ
UPLOADS_ANSWERS_PATH = UPLOADS_PATH.join("answers") # 解答ファイルのアップロードディレクトリ
UPLOADS_QUESTIONS_PATH = UPLOADS_PATH.join("questions") # 問題のテストデータアップロードディレクトリ
EVALUATE_WORK_DIR = Rails.root.join("tmp", "answers") # 評価時の作業ディレクトリ
DOCKER_PATH = Rails.root.join("docker") # Dockerイメージ用のパス
