class Premailer
  module Rails
    module CSSHelper
      extend self

      FileNotFound = Class.new(StandardError)

      STRATEGIES = [
        CSSLoaders::CacheLoader,
        CSSLoaders::FileSystemLoader,
        CSSLoaders::AssetPipelineLoader,
        CSSLoaders::NetworkLoader
      ]

      # Returns all linked CSS files concatenated as string.
      def css_for_doc(doc)
        css_urls_in_doc(doc).map { |url| css_for_url(url) }.join("\n")
      end

      def css_for_url(url)
        load_css(url).tap do |content|
          CSSLoaders::CacheLoader.store(url, content)
        end
      end

      private

      def css_urls_in_doc(doc)
        doc.search('link[@rel="stylesheet"]').map do |link|
          link.remove
          link.attributes['href'].to_s
        end
      end

      def load_css(url)
        STRATEGIES.each do |strategy|
          css = strategy.load(url)
          return css.force_encoding('UTF-8') if css
        end

        raise FileNotFound, %{File with URL "#{url}" could not be loaded by any strategy.}
      end
    end
  end
end
