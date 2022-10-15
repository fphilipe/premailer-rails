# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../../spec/rails_app/config/environment.rb", __FILE__)

require 'support/fixtures/message'
require 'support/fixtures/html'

require 'nokogiri'
