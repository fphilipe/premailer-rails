class Premailer
  module Rails
    module CSSHelper
      extend self

      STRATEGIES = [
        CSSLoaders::FileSystemLoader,
        CSSLoaders::AssetPipelineLoader,
        CSSLoaders::NetworkLoader,
      ]

      def reset_cache!
        @cache = {}
      end

      def cache
        reset_cache! if @cache.nil?
        @cache
      end

      # Returns all linked CSS files concatenated as string.
      def css_for_doc(doc)
        urls = css_urls_in_doc(doc)
        urls.map { |url| load_css(url).force_encoding('UTF-8') }.join("\n")
      end

      private

      def lookup_cached(url)
        return yield if rails_dev_env?

        if !cache.has_key?(url)
          cache[url] = yield(url)
        end

        cache[url]
      end

      def rails_dev_env?
        return false
        defined?(::Rails) && ::Rails.env.development?
      end

      def css_urls_in_doc(doc)
        doc.search('link[@rel="stylesheet"]').map do |link|
          link.attributes['href'].to_s
        end
      end

      def load_css(url)
        lookup_cached(url) do |url|
          css = nil

          STRATEGIES.each do |strategy|
            if css = strategy.load(url)
              ::Rails.logger.debug "premailer-rails: loaded asset #{url} using #{strategy}" if defined?(::Rails)
              break
            end
          end

          css
        end
      end
    end
  end
end
