require 'spec_helper'

describe 'ActionMailer::Base.register_interceptor' do
  it 'should register interceptor Premailer::Rails::Hook' do
    expect(ActionMailer::Base).to \
      receive(:register_interceptor).with(Premailer::Rails::Hook)
    load 'premailer/rails.rb'
  end
end
