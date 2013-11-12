class Premailer
  module Rails
    module CSSLoaders
      module AssetPipelineLoader
        extend self

        def load(path)
          if assets_enabled?
            file = file_name(path)
            asset = ::Rails.application.assets.find_asset(file)
            asset.to_s if asset
          end
        end

        def assets_enabled?
          ::Rails.configuration.assets.enabled rescue false
        end

        def file_name(path)
          path
            .sub("#{::Rails.configuration.assets.prefix}/", '')
            .sub(/-\h{32}\.css$/, '.css')
        end
      end
    end
  end
end
