module Fixtures
  module HTML
    extend self

    TEMPLATE = <<-HTML
<html>
  <head>
%s
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

    LINK = <<-LINK
<link rel='stylesheet' type='text/css' href='%s' />
    LINK

    def with_css_links(*files)
      links = []
      files.each do |file|
        links << LINK % "http://example.com/#{file}"
      end

      TEMPLATE % links.join("\n")
    end

    def with_no_css_link
      with_css_links
    end
  end
end
