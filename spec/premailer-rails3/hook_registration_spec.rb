require 'spec_helper'

describe 'ActionMailer::Base.register_interceptor' do
  it 'should register interceptor PremailerRails::Hook' do
    ActionMailer::Base \
      .expects(:register_interceptor) \
      .with(PremailerRails::Hook)
    load 'premailer-rails3.rb'
  end
end
