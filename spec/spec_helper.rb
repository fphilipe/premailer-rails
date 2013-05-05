if RUBY_VERSION >= '1.9'
  require 'coveralls'
  Coveralls.wear! do
    add_filter 'spec/'
  end
end

require 'premailer/rails'

require 'stubs/action_controller'
require 'stubs/action_mailer'
require 'stubs/rails'
require 'fixtures/message'
require 'fixtures/html'

require 'hpricot'
require 'nokogiri'

RSpec.configure do |config|
  config.mock_with :mocha
end
