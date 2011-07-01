module PremailerRails
  class Hook
    def self.delivering_email(message)
      options = {}

      # Grab the html part, if there is one, and grab all css file references
      html_part = message.html_part

      options[:css] = Hpricot(html_part.body.to_s).search('link[@type="text/css"]').collect do |css_file| 
        if css_file.attributes['href'].include?('?')
          css_file.attributes['href'][0..(css_file.attributes['href'].index('?') - 1)]
        else
          css_file.attributes['href']
        end
      end

      premailer = Premailer.new(html_part.body.to_s, options)

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
  end
end
