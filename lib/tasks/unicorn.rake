namespace :unicorn do
  desc "Start unicorn for development env."
  task(:start) do
    puts "Starting Unicorn server..."
    config = Rails.root.join('config', 'unicorn.rb')
    sh "bundle exec unicorn_rails -c #{config} -E production -D -p 3000"
    puts "Start!"
  end

  desc "Stop unicorn"
  task(:stop) do
    puts "Stopping Unicorn server..."
    unicorn_signal :QUIT
    puts "Stopped!"
  end

  desc "Restart unicorn with USR2"
  task(:restart) do
    puts "Restarting Unicorn server..."
    unicorn_signal :USR2
    puts "Restart!"
  end

  desc "Increment number of worker processes"
  task(:increment) { unicorn_signal :TTIN }

  desc "Decrement number of worker processes"
  task(:decrement) { unicorn_signal :TTOU }

  desc "Unicorn pstree (depends on psree command)"
  task(:pstree) do
    sh "pstree '#{unicorn_pid}'"
  end

  def unicorn_signal signal
    Process.kill signal, unicorn_pid
  end

  def unicorn_pid
    begin
      File.read("/tmp/unicorn.pid").to_i
    rescue Errno::ENOENT
      raise "Unicorn doesn't seem to be running"
    end
  end
end
