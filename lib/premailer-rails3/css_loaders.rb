module PremailerRails
  module CSSLoaders
    # Loads the CSS from cache when not in development env.
    module CacheLoader
      extend self

      def load(path)
        unless Rails.env.development?
          CSSHelper.cache[path]
        end
      end
    end

    # Loads the CSS from Hassle middleware if present.
    module HassleLoader
      extend self

      def load(path)
        if hassle_enabled?
          File.read("#{Rails.root}/tmp/hassle#{normalized_path(path)}")
        end
      end

      def hassle_enabled?
        Rails.configuration.middleware.include? Hassle rescue false
      end

      def normalized_path(path)
        path == :default ? '/stylesheets/email.css' : path
      end
    end

    # Loads the CSS from the asset pipeline.
    module AssetPipelineLoader
      extend self

      def load(path)
        if assets_enabled?
          file = file_name(path)
          asset = read_asset_from_pipeline(file)
          if asset.blank?
            request_and_unzip(file)
          else
            asset
          end
        end
      end

      def assets_enabled?
        Rails.configuration.assets.enabled rescue false
      end

      def assets_precompiled?
        # If on-the-fly asset compilation is disabled, we must be precompiling assets.
        !Rails.configuration.assets.compile rescue false
      end

      def file_name(path)
        if path == :default
          'email.css'
        else
          path.sub("#{Rails.configuration.assets.prefix}/", '') \
            .sub(/-.*\.css$/, '.css')
        end
      end

      def read_asset_from_pipeline(file)
        if assets_precompiled?
          # Read the precompiled asset
          asset_path = ActionController::Base.helpers.asset_path(file)
          File.read(File.join(Rails.public_path, asset_path))
        else
          # This will compile and return the asset
          Rails.application.assets.find_asset(file).to_s
        end
      end

      def request_and_unzip(file)
        url = [
          Rails.configuration.action_controller.asset_host,
          Rails.configuration.assets.prefix.sub(/^\//, ''),
          Rails.configuration.assets.digests[file]
        ].join('/')
        response = Kernel.open(url)

        begin
          Zlib::GzipReader.new(response).read
        rescue Zlib::GzipFile::Error, Zlib::Error
          response.rewind
          response.read
        end
      end
    end

    # Loads the CSS from the file system.
    module FileSystemLoader
      extend self

      def load(path)
        File.read("#{Rails.root}/public#{normalized_path(path)}")
      end

      def normalized_path(path)
        path == :default ? '/stylesheets/email.css' : path
      end
    end
  end
end
