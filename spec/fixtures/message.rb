require 'mail'

module Fixtures
  module Message
    extend self

    HTML_PART = <<-HTML
<html>
  <head>
  </head>
  <body>
    <p>
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
      veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
      commodo consequat.
    </p>
  </body>
</html>
    HTML

    HTML_PART_WITH_CSS = <<-HTML
<html>
  <head>
    <style type="text/css">
      p { color: red; }
    </style>
  </head>
  <body>
    <p>
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
      veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
      commodo consequat.
    </p>
  </body>
</html>
    HTML

    TEXT_PART = <<-TEXT
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    TEXT

    def with_parts(*part_types)
      message = base_message

      message.html_part do
        body HTML_PART
        content_type 'text/html; charset=UTF-8'
      end if part_types.include? :html

      message.text_part do
        body TEXT_PART
        content_type 'text/plain; charset=UTF-8'
      end if part_types.include? :text

      if part_types.include? :attachment
        alt_message = message
        message = base_message
        message.add_part(alt_message)

        message.add_file(fixture_dir + '/test.pdf')
      end

      message
    end

    def with_body(body_type)
      message = base_message

      case body_type
      when :html
        message.body = HTML_PART
        message.content_type 'text/html; charset=UTF-8'
      when :text
        message.body = TEXT_PART
        message.content_type 'text/plain; charset=UTF-8'
      end

      message
    end

    private

    def base_message
      Mail.new do
        to      'some@email.com'
        subject 'testing premailer-rails'
      end
    end
  end
end
