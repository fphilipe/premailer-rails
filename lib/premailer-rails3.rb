require 'premailer'
require 'premailer-rails3/css_helper'
require 'premailer-rails3/premailer'
require 'premailer-rails3/hook'

module PremailerRails
  @default_config = {
    :with_html_string => true,
    :input_encoding   => 'UTF-8'
  }
  @config = {}
  class << self
    attr_accessor :config
    attr_reader   :default_config
  end
end

ActionMailer::Base.register_interceptor(PremailerRails::Hook)
