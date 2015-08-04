require 'socket'
require 'securerandom'
require 'sidekiq/exception_handler'
require 'sidekiq/core_ext'

module Sidekiq
  ##
  # This module is part of Sidekiq core and not intended for extensions.
  #
  module Util
    include ExceptionHandler

    EXPIRY = 60 * 60 * 24

    def watchdog(last_words)
      yield
    rescue Exception => ex
      handle_exception(ex, { context: last_words })
      raise ex
    end

    def logger
      Sidekiq.logger
    end

    def redis(&block)
      Sidekiq.redis(&block)
    end

    def hostname
      ENV['DYNO'] || Socket.gethostname
    end

    def process_nonce
      @@process_nonce ||= SecureRandom.hex(6)
    end

    def identity
      @@identity ||= "#{hostname}:#{$$}:#{process_nonce}"
    end

    def fire_event(event, reverse=false)
      arr = Sidekiq.options[:lifecycle_events][event]
      arr.reverse! if reverse
      arr.each do |block|
        begin
          block.call
        rescue => ex
          handle_exception(ex, { event: event })
        end
      end
    end

    def want_a_hertz_donut?
      # what's a hertz donut?
      # punch!  Hurts, don't it?
      info = Sidekiq.redis {|c| c.info }
      if info['connected_clients'].to_i > 1000 && info['hz'].to_i >= 10
        Sidekiq.logger.warn { "Your Redis `hz` setting is too high at #{info['hz']}.  See mperham/sidekiq#2431.  Set it to 3 in #{info[:config_file]}" }
        true
      else
        Sidekiq.logger.debug { "Redis hz: #{info['hz']}.  Client count: #{info['connected_clients']}" }
        false
      end
    end

  end
end
