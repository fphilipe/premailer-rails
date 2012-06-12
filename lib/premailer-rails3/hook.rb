module PremailerRails
  class Hook
    def self.delivering_email(message)
      # If the mail only has one part, it may be stored in message.body. In that
      # case, if the mail content type is text/html, the body part will be the
      # html body.
      if message.html_part
        html_body = message.html_part.body.to_s
      elsif message.content_type =~ /text\/html/
        html_body = message.body.to_s
        message.body = nil
      end

      if html_body
        premailer = Premailer.new(html_body)
        charset   = message.charset


        # IMPORTANT: Plain text part must be generated before CSS is inlined.
        # Not doing so results in CSS declarations visible in the plain text
        # part.

        unless message.text_part
          text_part = {
            :content_type => "text/plain; charset=#{charset}",
            :body => premailer.to_plain_text
          }
        end

        html_part = {
          :content_type => "text/html; charset=#{charset}",
          :body => premailer.to_inline_css
        }

        if message.text_part && message.html_part
          message.html_part.body = html_part[:body]
          message.html_part.content_type = html_part[:content_type]

        elsif message.html_part
          message.parts.delete_if { |p| p.mime_type == 'text/html' && !p.attachment? }

          message.part :content_type => "multipart/alternative", :content_disposition => "inline" do |p|
            p.part text_part
            p.part html_part
          end
        else
          message.text_part do
            body text_part[:body]
            content_type text_part[:content_type]
          end

          message.html_part do
            body html_part[:body]
            content_type html_part[:content_type]
          end
        end

      end
    end
  end
end
