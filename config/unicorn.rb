# -*- coding: utf-8 -*-
WEB_CONCURRENCY = 3
SOCKET = "/tmp/unicorn.sock"
PID = "/tmp/unicorn.pid"
OUTLOG = "log/unicorn.log"
ERRLOG = "log/unicorn.log"

# ワーカー数(スレッド数)
worker_processes Integer(WEB_CONCURRENCY)
timeout 15
# 更新時のダウンタイム無し
preload_app true

# ソケットとpid
listen SOCKET
pid PID

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
stderr_path File.expand_path(ERRLOG)
stdout_path File.expand_path(OUTLOG)
