#! /bin/bash

bundle exec rake unicorn:start
bundle exec sidekiq -C $dir/config/sidekiq.yml -e production -d
