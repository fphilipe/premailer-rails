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
          'public/' + URI(url).path.sub(/\A#{relative_url_root}/, '')
        end

        def relative_url_root
          return '/' unless defined?(::Rails) &&
                            ::Rails.respond_to?(:configuration) &&
                            ::Rails.configuration.respond_to?(:relative_url_root)

          [::Rails.configuration.relative_url_root, '/'].join
        end

      end
    end
  end
end
