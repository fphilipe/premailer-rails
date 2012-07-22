require 'open-uri'
require 'zlib'

module PremailerRails
  module CSSHelper
    extend self

    @@css_cache = {}

    def css_for_doc(doc)
      css = doc.search('link[@type="text/css"]').map { |link|
              url = link.attributes['href'].to_s
              load_css_at_path(url) unless url.blank?
            }.reject(&:blank?).join("\n")
      css = load_css_at_path(:default) if css.blank?
      css
    end

    private

    def load_css_at_path(path)
      if path.is_a? String
        # Remove everything after ? including ?
        path = path[0..(path.index('?') - 1)] if path.include? '?'
        # Remove the host
        path = path.sub(/^https?\:\/\/[^\/]*/, '') if path.index('http') == 0
      end

      # Don't cache in development.
      if Rails.env.development? or not @@css_cache.include? path
        @@css_cache[path] =
          if defined? Hassle and Rails.configuration.middleware.include? Hassle
            file = path == :default ? '/stylesheets/email.css' : path
            File.read("#{Rails.root}/tmp/hassle#{file}")
          elsif assets_enabled?
            file = if path == :default
                     'email.css'
                   else
                     path.sub("#{Rails.configuration.assets.prefix}/", '') \
                         .sub(/-.*\.css$/, '.css')
                   end
            if asset = Rails.application.assets.find_asset(file)
              asset.to_s
            else
              request_and_unzip(file)
            end
          else
            file = path == :default ? '/stylesheets/email.css' : path
            File.read("#{Rails.root}/public#{file}")
          end
      end

      @@css_cache[path]
    rescue NoMethodError => ex
      # Log an error and return empty css:
      Rails.logger.try(:warn, ex.message)
      ''
    end

    def assets_enabled?
      Rails.configuration.assets.enabled rescue false
    end

    def request_and_unzip(file)
      url = [
        Rails.configuration.action_controller.asset_host,
        Rails.configuration.assets.prefix.sub(/^\//, ''),
        Rails.configuration.assets.digests[file]
      ].join('/')
      response = Kernel.open(url)
      begin
        Zlib::GzipReader.new(response).read
      rescue Zlib::GzipFile::Error, Zlib::Error
        response.rewind
        response.read
      end
    end
  end
end
