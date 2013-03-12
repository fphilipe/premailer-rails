require 'premailer'
require 'action_mailer'

require 'premailer-rails3/css_loaders'
require 'premailer-rails3/css_helper'
require 'premailer-rails3/premailer'
require 'premailer-rails3/hook'
require 'premailer-rails3/nokogiri_fix'

module PremailerRails
  @config = {
    :input_encoding     => 'UTF-8',
    :inputencoding      => 'UTF-8',
    :generate_text_part => true
  }
  class << self
    attr_accessor :config
  end
end

ActionMailer::Base.register_interceptor(PremailerRails::Hook)
