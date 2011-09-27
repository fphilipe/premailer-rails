module PremailerRails
  class Premailer < ::Premailer
    @@_css_cache = {}

    def initialize(html)
      options = {
        :with_html_string => true
      }

      super(html, options)

      load_css_from_default_file!
    end

    protected

    def load_css_from_default_file!
      # TODO and what if there are no rules and it's normal?
      if @css_parser.to_s == ''
        load_css_from_string(default_css_file || '')
      end
    end

    def default_css_file
      # Don't cache in development.
      if Rails.env.development? or not @@_css_cache.include? :default
        @@_css_cache[:default] =
          if defined? Hassle and Rails.configuration.middleware.include? Hassle
            File.read("#{Rails.root}/tmp/hassle/stylesheets/email.css")
          elsif Rails.configuration.try(:assets).try(:enabled)
            Rails.application.assets.find_asset('email.css').body
          else
            File.read("#{Rails.root}/public/stylesheets/email.css")
          end
      end
      @@_css_cache[:default]
    rescue => ex
      puts ex.message
      @@_css_cache[:default] = nil
    end
  end
end
