# TKB-procon_rails
筑波大学 高度IT学生プロジェクト

# 環境構築
## バージョン履歴
日付|Procsバージョン
-----|----------
2015/08/06|version-0.1
2015/10/07|version-0.4


## 検証環境
### OS
* Ubuntu 14.04.3

### Ruby
* 2.2.3

### Ruby on Rails
* 4.2.1

### MySQL
* 5.6.27

### Redis
* 3.0.6

### Python
* 3.4.3

### G++, GCC
* 4.8.4

### Docker
* 1.9.1

## 手順
* Ubuntu14.04.2がインストールされていることを前提

### 必要なソフトウェアのインストール
* `sudo apt-get install git build-essential libssl-dev libmysqld-dev libreadline-dev nodejs`

### Rubyのインストール
1. rbenv
1. `git clone https://github.com/sstephenson/rbenv.git ~/.rbenv`
2. `echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc`
3. `echo 'eval "$(rbenv init -)"' >> ~/.bashrc`
4. シェルの再起動 `exec $SHELL`
2. ruby-build
1. `git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build`
3. ruby
1. `rbenv install 2.2.3`
2. `rbenv rehash`
3. `rbenv global 2.2.3`
4. `ruby -v`

### Ruby on Railsのインストール
1. `gem install rails --version='4.2.1' --no-ri --no-rdoc`
2. `rails --version`

### MySQLのインストール
1. `sudo apt-get install mysql-server-5.6 mysql-client-5.6`
2. `mysql --version`

### Redis serverのインストール
1. `sudo add-apt-repository ppa:chris-lea/redis-server`
2. `sudo apt-get update`
3. `sudo apt-get install redis-server`
4. `redis-server --version`

### Dockerのインストール
[Docker install](https://docs.docker.com/installation/ubuntulinux/)

1. `curl -sSL https://get.docker.com/ | sh`
2. `sudo groupadd docker`
3. `sudo gpasswd -a ${USER} docker` dockerをsudo権限なしで実行できるようにする
4. Ubuntuの再起動


### Dockerコンテナ内で行っているので不要

> ### Python3のインストール
1. `sudo apt-get install python3`

>### GCCのインストール
1. `sudo add-apt-repository ppa:ubuntu-toolchain-r/test`
2. `sudo apt-get update`
3. `sudo apt-get install g++-4.9`
4. `gcc --version`
5. (もし4.8が表示されるならば) `sudo apt-get remove g++-4.8`

### SIMのインストール
[The software and text similarity tester SIM](http://dickgrune.com/Programs/similarity_tester/)
* `sudo apt-get install similarity-tester`

### Clonediggerのインストール
[Clone Digger](http://clonedigger.sourceforge.net/)
1. `sudo apt-get install python-setuptools`でPython Setup Toolsをインストール
2. `sudo easy_install clonedigger`でClone Diggerをインストール

### リポジトリのクローン
1. `git clone https://github.com/m-oke/TKB-procon_rails.git`
2. デフォルトは`develop`ブランチ
3. もし別のブランチを使う場合は`git checkout ブランチ名`

## 初期設定
1. `cd TKB-procon_rails`

#### ライブラリのインストール
1. `bundle install --path vendor/bundler`

#### DB設定
1. `cp config/database.yml.sample config/database.yml`
2. 17行目のpasswordにMySQLのパスワードを入力
3. `rake db:create` DBの作成
4. `rake db:migrate` テーブルの作成
5. `rake db:seed` 初期データの挿入

#### Dockerイメージの取得
1. `rails s -e production`で本番環境を構築
2. 無事サーバが起動したら`Ctrl-C`で終了
3. `docker images`で`procs/python_sandbox`と`procs/cpp_sandbox`が存在したら成功

## 使い方
* TKB-procon_railsディレクトリで操作
* `rails s` でサーバの起動
* `bundle exec sidekiq` でキューサーバの起動

### ログイン・新規登録
* 初期データのユーザでログイン
* 初期データについては下部に記載
* 新規登録はstudent
* teacherは現状では，`/users/teacher/new`から新規登録することで可能

### teahcerの場合
#### 授業作成
* '/'に「授業作成」ボタンが表示

#### 問題作成
* 「問題一覧」に「問題新規作成」ボタンが表示
* 現状では，作成した問題は，その授業とパブリック授業の両方に関連付けが行われる

#### 解答詳細
* 「問題詳細」の下部にある学生一覧から，該当する学生の「解答詳細」を見ることができる
* Note: 初期データではファイル生成していないのでエラーになる

### studentの場合
#### パブリック授業
* '/'の「問題一覧」や右上の「問題」で表示ものはパブリック授業として定義
* すべてのユーザが参加し，すべての問題が登録されている授業
* 他の授業の解答とは区別されている

#### 授業参加
* '/'に「授業参加」ボタンがあり，授業ページにある「授業コード」を入力することで参加できる
* この場合，studentとして参加する

#### 解答
* 「問題詳細」の下部からファイルをアップロードすることで解答
* Note: キューサーバを起動していないとPendingのままになる
* Note: もしプログラムの実行で問題があった場合はPendingのままになる

#### 解答詳細
* 「問題詳細」から解答済みの場合のみ「解答詳細」ボタンが表示
* Note: 初期データではファイル生成していないのでエラーになる


## 初期データ
* 詳しいデータは db/seed.rbに記述

### User
* パスワードは「testtest」で統一
* メールアドレスは「ユーザ名@user.com」で統一

> 例: root@user.com

> 例: teacher1@user.com

* 権限は「root, admin, teacher, student」の4つ
* root > admin > teacher > student
* 現状rootとadminは全てのデータを編集できるようになっている
* 権限の編集は'/admin/'から行うようになっているが，未実装なものが多い

1. root
* root
2. admin
* admin1~2
3. teacher
* teacher1~3
4. student
* student1~25

### Lesson
* idが1のLessonはパブリック授業として使用
* 「問題一覧」などで見れるものがパブリック授業
* 「授業作成」を行うと，授業コードが生成される

### UserLesson
* 授業とユーザの関連付け
* 「授業作成」や「授業参加」を行うと関連付けが行われる
* 「授業作成」ではis_teacherがtrueになる

### Question
* 問題を表すモデル
* 授業の中でのみ「問題作成」ができる
* 現状では，作成した問題は，その授業とパブリック授業の両方に関連付けが行われる

### Sample
* 問題の入出力サンプルを表すモデル
* 表示しか行わない

### TestDatum
* 解答の評価を行うためのテストデータ
* DBにはファイル名のみ保存
* Note: 初期データではDBに保存されるが実際のファイルは生成されない

### Answer
* 解答を表すモデル
* User, Lesson, Questionと関連付けされる
* Note: 初期データではDBに保存されるが実際のファイルは生成されない

## アップロードしたファイルの保存場所
* TKB-procon_rails/uploads
* /answers 解答データ
* /user_id/lesson_id/question_id/
* /questions テストデータ
* /question_id/

## トラブルシューティング
### DB内のデータのリセット
* `rake db:reset`または `scripts/db_all_clean.sh`
* Note: アップロードしたファイルは消えないため，不整合が起きる場合がある

### テーブル構造をリセット
* `rake db:migrate:reset`
* Note: 初期データを入れる場合は， `rake db:seed`

### 解答がPendingのまま操作ができない
* キューサーバが立っているかどうか
* `bundle exec sidekiq` で起動
* エラーでデータが更新されていない場合は該当のデータの削除
* `rails c` でコンソールの起動
* `Answer.last.destroy` で最後のデータの削除
* `Answer.find_by(:result => "P").destroy でPendingになっている最初のデータの削除
* `Answer.where(:result => "P").last.destroy でPendingになっている最後のデータの削除


### Railsのファイルを元に戻したい
* `git reset --hard HEAD`でHEADに戻す
