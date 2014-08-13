class Premailer
  module Rails
    class Railtie < ::Rails::Railtie
      config.after_initialize do
        ActionMailer::Base.register_interceptor(Premailer::Rails::Hook)

        if ActionMailer::Base.respond_to?(:register_preview_interceptor)
          ActionMailer::Base.register_preview_interceptor(Premailer::Rails::Hook)
        end
      end
    end
  end
end