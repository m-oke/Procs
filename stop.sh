#! /bin/bash
bundle exec rake unicorn:stop
bundle exec sidekiqctl quiet ./tmp/pids/sidekiq.pid
bundle exec sidekiqctl stop ./tmp/pids/sidekiq.pid 60
