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

          if not valid_uri?(uri) and defined?(::Rails)
            scheme, host =
              ::Rails.configuration.action_controller.asset_host.split(%r{:?//})
            scheme = 'http' if scheme.blank?
            uri.scheme ||= scheme
            uri.host ||= host
          end

          uri if valid_uri?(uri)
        end

        def valid_uri?(uri)
          uri.host.present? && uri.scheme.present?
        end
      end
    end
  end
end
