require 'spec_helper'

describe Premailer::Rails::Railtie do
  it 'supports instrumentation' do
    subscriber = double().as_null_object

    ActiveSupport::Notifications.subscribe('register_interceptors.premailer_rails') do
      registered_interceptors = Mail.class_variable_get('@@delivery_interceptors')
      expect(registered_interceptors).to include Premailer::Rails::Hook
      subscriber.call
    end

    ActiveSupport.run_load_hooks(:action_mailer, ActionMailer::Base)

    expect(subscriber).to have_received(:call).at_least(:once)
  end
end
