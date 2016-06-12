class Premailer
  module Rails
    module CSSLoaders
      module FileSystemLoader
        extend self

        def load(url)
          path = URI(url).path
          file_path = "public#{path}"
          File.read(file_path) if File.file?(file_path)
        end
      end
    end
  end
end
