class Premailer
  module Rails
    module CSSLoaders
      module AssetPipelineLoader
        extend self

        def load(url)
          if asset_pipeline_present?
            file = file_name(url)
            asset = ::Rails.application.assets.find_asset(file)
            asset.to_s if asset
          end
        end

        def asset_pipeline_present?
          defined?(::Rails) and ::Rails.application.respond_to?(:assets)
        end

        def file_name(url)
          path = URI(url).path
            .sub("#{::Rails.configuration.assets.prefix}/", '')
            .sub(/-\h{32}\.css$/, '.css')
          path.sub!(ENV['RAILS_RELATIVE_URL_ROOT'], '') if ENV['RAILS_RELATIVE_URL_ROOT']
          path
        end
      end
    end
  end
end
