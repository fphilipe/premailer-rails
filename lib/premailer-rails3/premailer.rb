module PremailerRails
  class Premailer < ::Premailer
    def initialize(html)
      super(html, :with_html_string => true,
                  :adapter => :hpricot)
    end

    def load_html(string)
      Hpricot(string)
    end
  end
end
