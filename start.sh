#! /bin/bash

bundle exec rake unicorn:start
bundle exec sidekiq -C ./config/sidekiq.yml -e production -d
