require 'premailer/rails'

require 'stubs/action_mailer'
require 'stubs/rails'
require 'fixtures/message'
require 'fixtures/html'

require 'hpricot' unless RUBY_PLATFORM == 'java'
require 'nokogiri'

RSpec.configure do |config|
end
