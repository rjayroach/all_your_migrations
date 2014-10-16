require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
#require "action_controller/railtie"
#require "action_mailer/railtie"
#require "action_view/railtie"
#require "sprockets/railtie"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "all_your_migrations"

module Dummy
  class Application < Rails::Application
    #config.autoload_paths += %W(#{config.root}/app/models/legacy)
    config.to_prepare do
      require File.expand_path('../../app/models/legacy/vendor', __FILE__)
      #require File.expand_path('../../app/models/merchant', __FILE__)
      # Note Legacy namespace isn't available until to_prepare
      unless Rails.application.config.respond_to? :migration_options  # only set it if it hasn't already been set
        Rails.application.config.migration_options = {namespaces: Legacy, primary_key: :legacy_id}
      end
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end

