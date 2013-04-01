class Premailer
  module Rails
    class Hook
      def self.delivering_email(message)
        # If the mail only has one part, it may be stored in message.body. In that
        # case, if the mail content type is text/html, the body part will be the
        # html body.
        if message.html_part
          html_body       = message.html_part.body.to_s
          needs_multipart = true
          message.parts.delete(message.html_part)
        elsif message.content_type =~ /text\/html/
          html_body       = message.body.to_s
          message.body    = nil
          needs_multipart = Rails.config[:generate_text_part]
        end

        if html_body
          premailer = CustomizedPremailer.new(html_body)
          charset   = message.charset

          if needs_multipart
            # IMPORTANT: Plain text part must be generated before CSS is inlined.
            # Not doing so results in CSS declarations visible in the plain text
            # part.
            text_part = message.text_part
            if Rails.config[:generate_text_part] && !message.text_part
              text_part = Mail::Part.new do
                    content_type "text/plain; charset=#{charset}"
                    body premailer.to_plain_text
                  end
            end

            html_part = Mail::Part.new do
              content_type "text/html; charset=#{charset}"
              body premailer.to_inline_css
            end

            if message.has_attachments?
              m = Mail::Part.new("Content-Type: multipart/alternative")
              m.text_part = text_part if text_part && !message.parts.include?(text_part)
              m.html_part = html_part

              # delete the old alternative part
              alt_part = message.find_first_mime_type("multipart/alternative")
              message.parts.delete(alt_part)
              message.add_part(m)
            else
              message.html_part = html_part
              message.text_part = text_part if text_part && !message.parts.include?(text_part)
            end

            message
          else
            message.body = premailer.to_inline_css
          end
        end
      end
    end
  end
end
