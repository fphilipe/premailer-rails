module PremailerRails
  class Hook
    def self.delivering_email(message)
      if html_part = message.html_part or (
        message.content_type =~ /text\/html/ and
        html_part = message.body
      )
        premailer = Premailer.new(html_part.body.to_s)
        plain_text = message.text_part.try(:body).try(:to_s)

        # reset the body and add two new bodies with appropriate types
        message.body = nil

        t_charset = message.charset

        message.html_part do
          content_type "text/html; charset=#{t_charset}"
          body premailer.to_inline_css
        end

        plain_text = premailer.to_plain_text if plain_text.blank?
        message.text_part do
          content_type "text/plain; charset=#{t_charset}"
          body plain_text
        end
      end
    end
  end
end
