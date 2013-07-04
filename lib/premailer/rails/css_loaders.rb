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
            if asset = ::Rails.application.assets.find_asset(file_name(path))
              asset.to_s
            else
              request_and_unzip(path)
            end
          end
        end

        def assets_enabled?
          ::Rails.configuration.assets.enabled rescue false
        end

        def file_name(path)
          CSSLoaders.extract_path(path)
            .sub("#{::Rails.configuration.assets.prefix}/", '')
            .sub(/-\h{32}\.css$/, '.css')
        end

        def request_and_unzip(url)
          ungzip(Kernel.open(normalize_asset_url(url)))
        end
        
        def ungzip(response)
          Zlib::GzipReader.new(response).read
        rescue Zlib::GzipFile::Error, Zlib::Error
          response.rewind
          response.read
        end

        def normalize_asset_url(url)
          unless url =~ %r{^(\w+:)?//}
            url = [
              ::Rails.configuration.action_controller.asset_host,
              ::Rails.configuration.assets.prefix.sub(/^\//, ''),
              ::Rails.configuration.assets.digests[url]
            ].join('/')
          end
          url = "http:" + url if url =~ %r{^//}
          url
        end
      end

      # Loads the CSS from the file system.
      module FileSystemLoader
        extend self

        def load(path)
          path = CSSLoaders.extract_path(path)
          File.read("#{::Rails.root}/public#{path}")
        end
 
      end
      # Extracts the path of a url.
      def self.extract_path(url)
        if url.is_a? String
          # Remove everything after ? including ?
          url = url[0..(url.index('?') - 1)] if url.include? '?'
          # Remove the host
          url = url.sub(/^https?\:\/\/[^\/]*/, '') if url.index('http') == 0
        end

        url
      end
    end
  end
end
