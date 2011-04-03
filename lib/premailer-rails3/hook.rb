module PremailerRails
  class Hook
    def self.delivering_email(message)
      premailer = Premailer.new(message.body)

      message.html_part do
        content_type message.content_type
        body premailer.to_inline_css
      end

      message.text_part do
        body premailer.to_plain_text
      end
    end
  end
end
