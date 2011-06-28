module PremailerRails
  class Hook
    def self.delivering_email(message)
      options = {}

      # Grab the html part, if there is one, and grab all css file references
      unless (html_part = message.html_part).blank?
        options[:css] = (Hpricot(html_part)/'link[@type="text/css"]').colect { |css_file| css_file.attributes['href'] }
      end

      premailer = Premailer.new(message.body.to_s, options)

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
