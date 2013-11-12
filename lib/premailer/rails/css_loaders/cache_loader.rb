class Premailer
  module Rails
    module CSSLoaders
      module CacheLoader
        extend self

        def load(path)
          unless ::Rails.env.development?
            CSSHelper.cache[path]
          end
        end
      end
    end
  end
end
