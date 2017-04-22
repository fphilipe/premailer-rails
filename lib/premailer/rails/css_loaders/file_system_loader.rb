class Premailer
  module Rails
    module CSSLoaders
      module FileSystemLoader
        extend self

        def load(url)
          file = file_name(url)
          File.read(file) if File.file?(file)
        end

        def file_name(url)
          path = URI(url).path
          if relative_url_root
            path = path.sub(/\A#{relative_url_root.chomp('/')}/, '')
          end
          "public#{path}"
        end

        def relative_url_root
          defined?(::Rails) &&
            ::Rails.respond_to?(:configuration) &&
            ::Rails.configuration.respond_to?(:relative_url_root) &&
            ::Rails.configuration.relative_url_root
        end
      end
    end
  end
end
