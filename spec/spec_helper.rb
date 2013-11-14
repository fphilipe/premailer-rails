require 'premailer/rails'

require 'stubs/action_mailer'
require 'stubs/rails'
require 'fixtures/message'
require 'fixtures/html'

require 'hpricot' unless RUBY_PLATFORM == 'java'
require 'nokogiri'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
