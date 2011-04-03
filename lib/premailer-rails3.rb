require 'premailer'
require 'premailer-rails3/premailer_rails'
require 'premailer-rails3/hook'

Mail.register_interceptor(PremailerRails::Hook)
