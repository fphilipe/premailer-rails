module PremailerRails
  class Premailer < ::Premailer
    def initialize(html, options = {})
      super(html, :with_html_string => true,
                  :adapter => :hpricot,
                  :css => css_file_for_options(options))
    end

    def load_html(string)
      Hpricot(string)
    end

    protected

    def css_file_for_options(options)
      if options.include?(:css)
        options[:css].is_a?(Array) ? options[:css] : [options[:css]]
      else
        default_css_file
      end
    end
    
    def default_css_file
      if defined? Hassle and Rails.configuration.middleware.include? Hassle
        ['tmp/hassle/stylesheets/email.css']
      else
        ['public/stylesheets/email.css']
      end
    end
  end
end
