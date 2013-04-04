require 'coveralls'
Coveralls.wear!

require 'premailer/rails'

require 'stubs/action_mailer'
require 'stubs/rails'
require 'fixtures/message'
require 'fixtures/html'

require 'hpricot'
require 'nokogiri'

RSpec.configure do |config|
  config.mock_with :mocha
end
