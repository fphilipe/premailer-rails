module PremailerRails
  class Hook
    def self.delivering_email(message)
      # If the mail only has one part, it may be stored in message.body. In that
      # case, if the mail content type is text/html, the body part will be the
      # html body.
      if message.html_part
        html_body       = message.html_part.body.to_s
        needs_multipart = true
      elsif message.content_type =~ /text\/html/
        html_body       = message.body.to_s
        message.body    = nil
        needs_multipart = PremailerRails.config[:generate_text_part]
      end

      if html_body
        premailer = Premailer.new(html_body)
        charset   = message.charset

        if needs_multipart
          # IMPORTANT: Plain text part must be generated before CSS is inlined.
          # Not doing so results in CSS declarations visible in the plain text
          # part.
          if PremailerRails.config[:generate_text_part] \
          and not message.text_part
            message.text_part do
              content_type "text/plain; charset=#{charset}"
              body premailer.to_plain_text
            end
          end

          message.html_part do
            content_type "text/html; charset=#{charset}"
            body premailer.to_inline_css
          end
        else
          message.body = premailer.to_inline_css
        end
      end
    end
  end
end
