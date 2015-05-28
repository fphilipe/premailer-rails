class Premailer
  module Rails
    module CSSLoaders
      module CacheLoader
        extend self

        def reset!
          @cache = {}
        end

        def cache
          reset! if @cache.nil?
          @cache
        end

        def load(url)
          unless development_env?
            if cached = CSSHelper.cache[url]
              @cache[url] = cached
            end
          end
        end

        def development_env?
          defined?(::Rails) and ::Rails.env.development?
        end
      end
    end
  end
end
