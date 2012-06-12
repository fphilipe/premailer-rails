module PremailerRails
  class Premailer < ::Premailer
    def initialize(html)
      # In order to pass the CSS as string to super it is necessary to access
      # the parsed HTML beforehand. To do so, the adapter needs to be
      # initialized. The ::Premailer::Adaptor handles the discovery of a
      # suitable adaptor (Nokogiri or Hpricot). To make load_html work, an
      # adaptor needs to be included and @options[:with_html_string] needs to be
      # set. For further information, refer to ::Premailer#initialize.
      default_options = { :with_html_string => true }
      @options = default_options.merge PremailerRails.config

      ::Premailer.send(:include, Adapter.find(Adapter.use))
      doc = load_html(html)

      @options[:css_string] = CSSHelper.css_for_doc(doc)

      super(html, @options)
    end
  end
end
