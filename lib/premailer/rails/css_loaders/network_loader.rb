require 'uri'

class Premailer
  module Rails
    module CSSLoaders
      module NetworkLoader
        extend self

        def load(url)
          Net::HTTP.get(uri_for_url(url))
        end

        def uri_for_url(url)
          URI(url).tap do |uri|
            scheme, host =
              ::Rails.configuration.action_controller.asset_host.split(%r{:?//})
            scheme = 'http' if scheme.blank?
            uri.scheme ||= scheme
            uri.host ||= host
          end
        end
      end
    end
  end
end
