# Procs
ProcsはWebインターフェースのプログラミング教育向け学習支援システムです．
プログラミングチャレンジの問題を利用して教育を行う大学等の教育機関を対象としています．
**授業管理**，**問題管理**，**サンドボックス環境における自動評価**および**剽窃チェック機能**といった特徴があります．

## バージョン履歴
日付|Procsバージョン
-----|----------
2015/08/06|version-0.1
2015/10/07|version-0.4

## 検証&利用環境
### OS
* Ubuntu 14.04

### Ruby
* 2.2

### Ruby on Rails
* 4.2.1

### MySQL
* 5.6

### Redis
* 3.0

### Python
* 3.4.3

### G++, GCC
* 4.8.4

### Docker
* 1.10

### [The software and text similarity tester SIM](http://dickgrune.com/Programs/similarity_tester/)

### [Clone Digger](http://clonedigger.sourceforge.net/)

## インストール手順
### 事前準備
* Ubuntu14.04等のDebian系Linuxサーバ環境
    * その他のOSの場合は`scripts/install.sh`を参考に手動でお願いします．
* Microsoft Bing Search API Key
    * Web剽窃チェック機能を利用するためには[Bing](https://www.bing.com/)のAPI Keyが必要です．
    * [Bing Search API](http://datamarket.azure.com/dataset/bing/search)


### インストール
1. Procsのclone

    `git clone https://github.com/m-oke/Procs.git`
2. インストールスクリプトの実行し，必要事項を入力

    `cd Procs/scripts`
    `./install.sh`

3. 再ログイン(docker実行権限の変更のため)
4. サーバにブラウザでアクセス

    `http://yourdomain/`


# FAQ
#### アクセスしても表示されない
* Webサーバが起動しているかの確認
    * `sudo service nginx status`
    * `cd Procs`
    * `bundle exec rake unicorn:pstree`

* 起動していなければWebサーバの再起動
    * `sudo service nginx restart`
    * `./stop.sh`
    * `./start.sh`

* DBが作成されているか確認
    * `cd Procs`
    * `bundle exec rake db:create RAILS_ENV=production`

#### システム管理者の(初期ユーザ)の編集
* データベースを操作して編集してください．
    * `cd Procs`
    * `bundle exec rails c -e production`
    * `u = User.find(1)`
    * `u.nickname = 'rootuser'`
    * `u.save`

#### Webサーバの設定を変更したい
* `/etc/nginx/conf.d/unicorn.conf`を適宜変更してください．

#### プログラム実行環境等について
* githubの[wiki](https://github.com/m-oke/Procs/wiki)を参照してください．
