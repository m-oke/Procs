require 'minitest/unit'
require 'libnotify'
require 'minitest/libnotify/version'

module MiniTest
  # Test notifier for minitest via libnotify.
  #
  # == Usage
  #
  # In your test helper put:
  #
  #   require 'minitest/autorun'
  #   require 'minitest/libnotify'
  #
  # == Config
  #
  #  require 'minitest/autorun'
  #  require 'minitest/libnotify'
  #
  #  reporter = MiniTest::Unit.output
  #  reporter.config[:global][:description]  = "TESTS"
  #  reporter.config[:pass][:description]    = proc { |desc| "#{desc} :)" }
  #  reporter.config[:fail][:description]    = proc { |desc| "#{desc} :(" }
  #  reporter.config[:fail][:icon_path]      = "face-crying.*"
  class Libnotify
    class << self
      attr_accessor :default_config
    end

    # Default configuration
    self.default_config = {
      :global => {
        :regexp       => /(\d+) failures, (\d+) errors/,
        :timeout      => 2.5,
        :append       => false,
        :description  => proc { [ defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby", RUBY_VERSION, RUBY_PLATFORM ].join(" ") },
      },
      :pass => {
        :description  => proc { |description| ":-) #{description}" },
        :urgency      => :critical,
        :icon_path    => "face-laugh.*"
      },
      :fail => {
        :description  => proc { |description| ":-( #{description}" },
        :urgency    => :critical,
        :icon_path  => "face-angry.*"
      }
    }

    attr_accessor :config

    def initialize(io, config = self.class.default_config)
      @io         = io
      @libnotify  = nil
      @config     = config.dup
    end

    def puts(*o)
      notify(o.first) if libnotify
      @io.puts(*o)
    end

    def method_missing(msg, *args, &block)
      @io.send(msg, *args, &block)
    end

    def respond_to?(msg)
      @io.respond_to?(msg) || super
    end

    private

    def notify(body)
      match = config_for(:regexp).match(body)
      return unless match
      state = match.captures.any? { |c| c.to_i > 0 } ? :fail : :pass

      default_description = config_for(:description)
      libnotify.body      = config_for(:body, state, body)
      libnotify.summary   = config_for(:description, state, default_description)
      libnotify.urgency   = config_for(:urgency, state)
      libnotify.icon_path = config_for(:icon_path, state)
      libnotify.show!
    end

    def libnotify
      if @libnotify.nil?
        @libnotify = begin
          require 'libnotify'
          ::Libnotify.new(:timeout => config_for(:timeout), :append => config_for(:append))
        rescue => e
          warn e
          false
        end
      end
      @libnotify
    end

    def config_for(name, state=:global, default=nil)
      value = config[state][name] || config[:global][name]
      if value.respond_to?(:call)
        value.call(default)
      else
        value.nil? ? default : value
      end
    end
  end
end

MiniTest::Unit.output = MiniTest::Libnotify.new(MiniTest::Unit.output)
