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
        load_css_from_string(default_css_file)
      end
    end

    def default_css_file
      # Don't cache in development.
      if Rails.env.development? || !@@_css_cache.include?(:default)
        @@_css_cache[:default] =
          if defined?(Hassle) && Rails.configuration.middleware.include?(Hassle) && File.exists?(default_css_filename_for_hassle)
            File.read(default_css_filename_for_hassle)
          elsif Rails.configuration.try(:assets).try(:enabled)
            Rails.application.assets.find_asset('email.css').try(:body) || ''
          elsif File.exists?(default_css_filename)
            File.read(default_css_filename)
          end
      end
      @@_css_cache[:default]
    end

    def default_css_filename_for_hassle
      File.join(Rails.root.to_s, 'tmp', 'hassle', 'stylesheets', 'email.css')
    end

    def default_css_filename
      File.join(Rails.root.to_s, 'public', 'stylesheets', 'email.css')
    end
  end
end
