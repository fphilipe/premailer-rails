require 'premailer'
require 'premailer-rails3/css_helper'
require 'premailer-rails3/premailer'
require 'premailer-rails3/hook'

ActionMailer::Base.register_interceptor(PremailerRails::Hook)
