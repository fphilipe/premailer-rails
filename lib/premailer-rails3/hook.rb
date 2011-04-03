module PremailerRails
  class Hook
    def self.delivering_email(message)
      premailer = Premailer.new(message.body.to_s)

      # reset the body and add two new bodies with appropriate types
      message.body = nil

      message.html_part do
        content_type "text/html; charset=utf-8"
        debugger
        body premailer.to_inline_css
      end

      message.text_part do
        body premailer.to_plain_text
      end
    end
  end
end
