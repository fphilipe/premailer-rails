class Premailer
  module Rails
    class Railtie < ::Rails::Railtie
      ActiveSupport.on_load(:action_mailer) do
        ::Premailer::Rails.register_interceptors
      end
    end
  end
end
