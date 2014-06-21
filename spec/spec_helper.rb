if RUBY_ENGINE == 'ruby'
  if ENV['CI']
    require 'coveralls'
    Coveralls::Output.silent = true
    Coveralls.wear! do
      add_filter 'spec/'
    end
  else
    require 'simplecov'
    SimpleCov.start
  end
end

require 'premailer/rails'

require 'support/stubs/action_mailer'
require 'support/stubs/rails'
require 'support/fixtures/message'
require 'support/fixtures/html'

require 'hpricot' unless RUBY_PLATFORM == 'java'
require 'nokogiri'
