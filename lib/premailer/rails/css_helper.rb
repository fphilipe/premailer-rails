class Premailer
  module Rails
    module CSSHelper
      extend self

      STRATEGIES = [
        CSSLoaders::CacheLoader,
        CSSLoaders::FileSystemLoader,
        CSSLoaders::AssetPipelineLoader,
        CSSLoaders::NetworkLoader
      ]

      # Returns all linked CSS files concatenated as string.
      def css_for_doc(doc)
        urls = css_urls_in_doc(doc)
        urls.map { |url| load_css(url).force_encoding('UTF-8') }.join("\n")
      end

      private

      def css_urls_in_doc(doc)
        doc.search('link[@rel="stylesheet"]').map do |link|
          link.attributes['href'].to_s
        end
      end

      def load_css(url)
        STRATEGIES.each do |strategy|
          if css = strategy.load(url)
            ::Rails.logger.debug "premailer-rails: loaded asset #{url} using #{strategy}"
            return css
          end
        end
        # if we don't return nil, it will return the array STRATEGIES
        nil
      end
    end
  end
end
