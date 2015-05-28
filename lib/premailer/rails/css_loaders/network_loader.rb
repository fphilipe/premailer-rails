class Premailer
  module Rails
    module CSSLoaders
      module NetworkLoader
        extend self

        def load(url)
          if uri = uri_for_url(url)
            Net::HTTP.get(uri)
          end
        end

        def uri_for_url(url)
          uri = URI(url)

          if uri.host.present?
            return uri if uri.scheme.present?
            URI("http://#{uri.to_s}")
          elsif asset_host_present?
            scheme, host = asset_host.split(%r{:?//})
            scheme, host = host, scheme if host.nil?
            scheme = 'http' if scheme.blank?
            path = url
            URI(File.join("#{scheme}://#{host}", path))
          end
        end

        def valid_uri?(uri)
          uri.host.present? && uri.scheme.present?
        end

        def asset_host_present?
          ::Rails.configuration.action_controller.asset_host.present?
        end

        def asset_host
          config = ::Rails.configuration.action_controller.asset_host
          config.respond_to?(:call) ? config.call : config
        end
      end
    end
  end
end
