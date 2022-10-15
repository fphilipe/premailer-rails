require_relative 'boot'

require 'action_controller/railtie'
require 'action_mailer/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Example
  class Application < Rails::Application
    config.load_defaults 7.0
  end
end
