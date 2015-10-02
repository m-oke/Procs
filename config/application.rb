require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Procs
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/constraints)
     # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja

    # Do not swallow errors in after_commit/after_rollback callbacks
    config.time_zone = 'Asia/Tokyo'
    config.active_record.default_timezone = :local
    config.active_record.raise_in_transactional_callbacks = true
    config.action_controller.permit_all_parameters = true
    config.active_job.queue_adapter = :sidekiq
    config.assets.compile =true

    config.after_initialize do
      FileUtils.mkdir_p(DOCKER_PATH) unless FileTest.exist?(DOCKER_PATH)
      if FileTest.exist?("#{DOCKER_PATH}/.git")
        Dir.chdir(DOCKER_PATH)
        `git pull `#https://github.com/m-oke/TKB-procon_sandbox.git `
      else
        `git clone https://github.com/m-oke/TKB-procon_sandbox.git #{DOCKER_PATH}`
      end
      `docker build -t procs/python_sandbox #{DOCKER_PATH}/python_sandbox`
    end
  end
end
