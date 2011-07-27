module PremailerRails
  class Hook
    def self.delivering_email(message)
      # If there's no HTML part then there isn't much we can do anyway. 
      return if message.html_part == nil

      html_part = message.html_part
      premailer = Premailer.new(html_part.body.to_s, { :css => extract_css_paths_from_body(html_part.body) })

      # reset the body and add two new bodies with appropriate types
      message.body = nil

      message.html_part do
        content_type "text/html; charset=utf-8"
        body premailer.to_inline_css
      end

      message.text_part do
        body premailer.to_plain_text
      end
    end

    protected

    # Scan the HTML mailer template for CSS files, specifically Link tags with types 
    # of text/css  (other ways of including CSS are not supported). Once it's finds
    # them it returns an Array that contains the URL of each of the CSS files.
    def self.extract_css_paths_from_body(html_body)
      css_file_paths = Hpricot(html_body.to_s).search('link[@type="text/css"]').collect do |css_file| 
        if css_file.attributes['href'].include?('?')
          css_file.attributes['href'][0..(css_file.attributes['href'].index('?') - 1)]
        else
          css_file.attributes['href']
        end
      end

      css_file_paths.empty?? nil : css_file_paths.to_a
    end
  end
end
