require_relative 'boot'

require "action_mailer/railtie"
require "action_view/railtie"

if ENV.fetch("ASSETS_GEM", "sprockets-rails") == "sprockets-rails"
  require "sprockets/railtie"
end

require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
  end
end
