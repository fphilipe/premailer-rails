class Premailer
  module Rails
    module CSSLoaders
      module FileSystemLoader
        extend self

        def load(url)
          file = file_name(url)
          File.read(file) if file && File.file?(file)
        end

        def file_name(url)
          path = URI(url).path
          if relative_url_root
            path = path.sub(/\A#{relative_url_root.chomp('/')}/, '')
          end
          file = asset_filename(path)
          file if inside_public_directory?(file)
        end

        def inside_public_directory?(file)
          public_directory = File.join(File.expand_path(asset_filename('')), '')
          File.expand_path(file).start_with?(public_directory)
        end

        def asset_filename(filename)
          if defined?(::Rails) && ::Rails.respond_to?(:root)
            File.join(::Rails.root, 'public', filename)
          else
            File.join('public', filename)
          end
        end

        def relative_url_root
          defined?(::Rails) &&
            ::Rails.respond_to?(:configuration) &&
            ::Rails.configuration.respond_to?(:relative_url_root) &&
            ::Rails.configuration.relative_url_root
        end
      end
    end
  end
end
