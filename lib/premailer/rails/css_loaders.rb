require 'uri'

class Premailer
  module Rails
    module CSSLoaders
      # Loads the CSS from cache when not in development env.
      module CacheLoader
        extend self

        def load(path)
          unless ::Rails.env.development?
            CSSHelper.cache[path]
          end
        end
      end

      # Loads the CSS from the asset pipeline.
      module AssetPipelineLoader
        extend self

        def load(path)
          if assets_enabled?
            file = file_name(path)
            if asset = ::Rails.application.assets.find_asset(file)
              asset.to_s
            else
              Net::HTTP.get(uri_for_path(path))
            end
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

        def uri_for_path(path)
          URI(path).tap do |uri|
            scheme, host =
              ::Rails.configuration.action_controller.asset_host.split(%r{:?//})
            scheme = 'http' if scheme.blank?
            uri.scheme ||= scheme
            uri.host ||= host
          end
        end
      end

      # Loads the CSS from the file system.
      module FileSystemLoader
        extend self

        def load(path)
          file_path = "#{::Rails.root}/public#{path}"
          File.read(file_path) if File.exist?(file_path)
        end
      end
    end
  end
end
