class Premailer
  module Rails
    module CSSLoaders
      module CacheLoader
        extend self

        def load(url)
          unless development_env?
            if cached = CSSHelper.cache[url]
              ::Rails.logger.debug "premailer-rails: loaded asset from cache (#{url})"
              cached
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
