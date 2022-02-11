class Premailer
  module Rails
    module CSSLoaders
      module PropshaftLoader
        extend self

        def load(url)
          return unless propshaft_present?

          file = file_name(url)
          ::Rails.application.assets.load_path.find(file)&.content
        end

        def file_name(url)
          prefix = File.join(
            ::Rails.configuration.relative_url_root.to_s,
            ::Rails.configuration.assets.prefix.to_s,
            '/'
          )
          URI(url).path
            .sub(/\A#{prefix}/, '')
            .sub(/-(\h{40})\.css\z/, '.css')
        end

        def propshaft_present?
          defined?(::Rails) &&
            ::Rails.try(:application).try(:assets).class.name == "Propshaft::Assembly"
        end
      end
    end
  end
end
