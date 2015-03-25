class Premailer
  module Rails
    module CSSLoaders
      module NetworkLoader
        extend self

        def load(url)
          uri = uri_for_url(url)
          Net::HTTP.get(uri) if uri
        end

        def uri_for_url(url)
          uri = URI(url)
          return uri if valid_uri?(uri)

          return nil unless asset_host.present?
          URI("#{scheme}://#{host}#{url}")
        end

        private

        def scheme
          asset_host.start_with?('https://') ? 'https' : 'http'
        end

        def host
          asset_host.sub(/^http[s]?:\/\//,'')
        end

        def valid_uri?(uri)
          uri.host.present? && uri.scheme.present?
        end

        def asset_host
          host = ::Rails.configuration.action_controller.asset_host

          if host.respond_to?(:call)
            host.call
          else
            host
          end
        end
      end
    end
  end
end
