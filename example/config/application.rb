require_relative 'boot'

require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
if ENV.fetch("ASSETS_GEM", "sprockets") == "sprockets"
  require "sprockets/railtie"
end
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
