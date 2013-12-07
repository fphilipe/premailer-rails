require 'premailer/adapter/nokogiri'

Premailer::Adapter::Nokogiri.module_eval do
  # Patch load_html method to fix character encoding issues.
  def load_html(html)
    html = html.force_encoding('UTF-8').encode!
    ::Nokogiri::HTML(html) { |c| c.recover }
  end
end
