class Premailer
  module Rails
    module CSSLoaders
      module AssetPipelineLoader
        extend self

        def load(url)
          return unless asset_pipeline_present?

          file = file_name(url)
          ::Rails.application.assets_manifest.find_sources(file).first
        rescue Errno::ENOENT, TypeError => _error
        end

        def file_name(url)
          prefix = File.join(
            ::Rails.configuration.relative_url_root.to_s,
            ::Rails.configuration.assets.prefix.to_s,
            '/'
          )
          URI(url).path
            .sub(/\A#{prefix}/, '')
            .sub(/-(\h{32}|\h{64})\.css\z/, '.css')
        end

        def asset_pipeline_present?
          defined?(::Rails) &&
            ::Rails.respond_to?(:application) &&
            ::Rails.application &&
            ::Rails.application.respond_to?(:assets_manifest) &&
            ::Rails.application.assets_manifest
        end
      end
    end
  end
end
