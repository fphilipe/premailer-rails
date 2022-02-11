require_relative 'boot'

require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"

begin
  require "sprockets/railtie"
rescue LoadError
end

require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
  end
end
