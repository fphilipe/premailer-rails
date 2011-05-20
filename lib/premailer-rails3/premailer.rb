module PremailerRails
  class Premailer < ::Premailer
    def initialize(html)
      if defined? Hassle and Rails.configuration.middleware.include? Hassle
        css_file = 'tmp/hassle/stylesheets/email.css'
      else
        css_file = nil # load by requesting the css file specified in the HTML
      end

      super(html, :with_html_string => true,
                  :adapter => :hpricot,
                  :css => css_file)
    end

    def load_html(string)
      Hpricot(string)
    end
  end
end
