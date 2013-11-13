class Premailer
  module Rails
    module CSSLoaders
      module CacheLoader
        extend self

        def load(url)
          unless development_env?
            CSSHelper.cache[url]
          end
        end

        def development_env?
          defined?(::Rails) and ::Rails.env.development?
        end
      end
    end
  end
end
