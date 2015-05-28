class Premailer
  module Rails
    module CSSLoaders
      module FileSystemLoader
        extend self

        def load(url)
          path = URI(url).path

          # Remove leading slash if it exists
          path = path[1..-1] if path[0,1] == "/"

          file_path = ::Rails.root.join("public/#{path}").to_s

          if File.exist?(file_path)
            File.read(file_path)
          end
        end
      end
    end
  end
end
