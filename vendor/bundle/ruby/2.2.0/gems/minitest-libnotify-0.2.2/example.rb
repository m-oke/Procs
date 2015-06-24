require 'minitest/libnotify'
require 'stringio'

reporter = MiniTest::Unit.output
reporter.config[:global][:description]  = "TESTS"
reporter.config[:pass][:description]    = proc { |desc| "#{desc} :)" }
reporter.config[:fail][:description]    = proc { |desc| "#{desc} :(" }
reporter.config[:fail][:icon_path]      = "face-crying*"

reporter.puts "0 failures, 1 errors"
reporter.puts "0 failures, 0 errors"

reporter.puts "other"
