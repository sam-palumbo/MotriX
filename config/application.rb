require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require "dotenv-rails" if Rails.env.development? || Rails.env.test?

module Motrix
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    config.time_zone = "Brasilia"
    config.i18n.default_locale = :"pt-BR"
    config.active_support.inflector_locale = :"pt-BR"
    config.generators do |generator|
      generator.orm :active_record, primary_key_type: :uuid
      generator.helper false
      generator.assets false
      generator.test_framework :test_unit, fixture: false
    end

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Use Ruby format for schema dumping for SQLite compatibility
    config.active_record.schema_format = :ruby if Rails.env.test?

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
