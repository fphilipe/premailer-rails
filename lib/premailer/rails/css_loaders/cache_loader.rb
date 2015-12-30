class Premailer
  module Rails
    module CSSLoaders
      module CacheLoader
        extend self

        @cache = {}

        def load(url)
          @cache[url] unless development_env?
        end

        def store(url, content)
          @cache[url] ||= content unless development_env?
        end

        def clear!
          @cache = {}
        end

        def development_env?
          defined?(::Rails) && ::Rails.env.development?
        end
      end
    end
  end
end
