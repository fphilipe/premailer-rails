class Premailer
  module Rails
    module CSSLoaders
      module PropshaftLoader
        extend self

        def load(url)
          return unless propshaft_present?

          file = file_name(url)
          asset = ::Rails.application.assets.load_path.find(file)

          ::Rails.application.assets.compilers.compile(asset) if asset
        end

        def file_name(url)
          prefix = File.join(
            ::Rails.configuration.relative_url_root.to_s,
            ::Rails.configuration.assets.prefix.to_s,
            '/'
          )

          # Path extraction logic from Propshaft.
          # See https://github.com/rails/propshaft/blob/390381548b125e8721c8aef1b9d894b7cc8bd868/lib/propshaft/server.rb#L35-L41
          full_path = URI(url).path.sub(/\A#{prefix}/, '')
          digest = full_path[/-([0-9a-zA-Z]{7,128}(?:\.digested)?)\.[^.]+\z/, 1]
          path = digest ? full_path.sub("-#{digest}", "") : full_path

          path
        end

        def propshaft_present?
          defined?(::Propshaft) && defined?(::Rails)
        end
      end
    end
  end
end
