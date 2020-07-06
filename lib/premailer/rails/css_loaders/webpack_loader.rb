class Premailer
  module Rails
    module CSSLoaders
      module WebpackLoader
        extend self

        def load(url)
          return unless webpacker_present?

          path = Webpacker.instance.manifest.lookup(name)
          return if !path
          if Webpacker.config.compile?
            URI.open(url_to_asset(path)).read
          else
            Webpacker.config.public_output_path.join(path).read
          end
        end

        def webpacker_present?
          defined?(::Webpacker)
        end
      end
    end
  end
end
