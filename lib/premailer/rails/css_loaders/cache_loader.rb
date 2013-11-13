class Premailer
  module Rails
    module CSSLoaders
      module CacheLoader
        extend self

        def load(url)
          unless ::Rails.env.development?
            CSSHelper.cache[url]
          end
        end
      end
    end
  end
end
