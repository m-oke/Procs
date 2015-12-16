# -*- coding: utf-8 -*-
# TODO: nginxの設定
# ワーカー数(スレッド数)
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

timeout 15
# 更新時のダウンタイム無し
preload_app true

# ソケットとpid
listen "#{ENV['RAILS_ROOT']}/tmp/unicorn.sock"
pid "#{ENV['RAILS_ROOT']}/tmp/unicorn.pid"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

#ログ
stderr_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
