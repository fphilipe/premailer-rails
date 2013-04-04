require 'open-uri'
require 'zlib'

class Premailer
  module Rails
    module CSSHelper
      extend self

      @cache = {}
      attr :cache

      STRATEGIES = [
        CSSLoaders::CacheLoader,
        CSSLoaders::AssetPipelineLoader,
        CSSLoaders::FileSystemLoader
      ]

      # Returns all linked CSS files concatenated as string.
      def css_for_doc(doc)
        urls = css_urls_in_doc(doc)
        urls.map { |url| load_css(url) }.join("\n")
      end

      private

      def css_urls_in_doc(doc)
        doc.search('link[@type="text/css"]').map do |link|
          link.attributes['href'].to_s
        end
      end

      def load_css(url)
        path = extract_path(url)

        @cache[path] = STRATEGIES.each do |strategy|
                         css = strategy.load(path)
                         break css if css
                       end
      end

      # Extracts the path of a url.
      def extract_path(url)
        if url.is_a? String
          # Remove everything after ? including ?
          url = url[0..(url.index('?') - 1)] if url.include? '?'
          # Remove the host
          url = url.sub(/^https?\:\/\/[^\/]*/, '') if url.index('http') == 0
        end

        url
      end
    end
  end
end
