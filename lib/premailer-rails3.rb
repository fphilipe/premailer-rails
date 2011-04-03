require 'premailer'
require 'hpricot'
require 'premailer-rails3/premailer'
require 'premailer-rails3/hook'

Mail.register_interceptor(PremailerRails::Hook)
