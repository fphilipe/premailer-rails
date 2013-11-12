class Premailer
  module Rails
    module CSSLoaders
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
