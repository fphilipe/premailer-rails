require 'premailer/adapter/nokogiri'

Premailer::Adapter::Nokogiri.module_eval do
  # Patch load_html method to fix character encoding issues.
  def load_html(html)
    if RUBY_VERSION.to_f >= 1.9
      html = html.force_encoding('UTF-8').encode!
      ::Nokogiri::HTML(html) {|c| c.recover }
    else
      # :nocov:
      ::Nokogiri::HTML(html, nil, 'UTF-8') {|c| c.recover }
      # :nocov:
    end
  end
end
