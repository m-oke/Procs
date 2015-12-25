#! /bin/bash
bundle exec rake unicorn:stop
bundle exec sidekiqctl quiet ./tmp/pids/sidekiq.pid
