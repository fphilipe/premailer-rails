module PremailerRails
  class Premailer < ::Premailer
    def initialize(html)
      # In order to pass the CSS as string to super it is necessary to access
      # the parsed HTML beforehand. To do so, the adapter needs to be
      # initialized. The ::Premailer::Adaptor handles the discovery of a
      # suitable adaptor (Nokogiri or Hpricot). To make load_html work, an
      # adaptor needs to be included and @options[:with_html_string] needs to be
      # set. For further information, refer to ::Premailer#initialize.
      @options = { :with_html_string => true }
      ::Premailer.send(:include, Adapter.find(Adapter.use))
      doc = load_html(html)

      options = PremailerRails.config.reject do |key, _|
        key == :generate_text_part
      end.merge(
        :with_html_string => true,
        :css_string       => CSSHelper.css_for_doc(doc)
      )
      super(html, options)
    end
  end
end
