module PremailerRails
  module CSSHelper
    extend self

    @@css_cache = {}

    def css_for_doc(doc)
      css = doc.search('link[@type="text/css"]').map { |link|
              url = link.attributes['href']
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
        path = path.gsub(/^https?\:\/\/[^\/]*/, '') if path.index('http') == 0
      end

      # Don't cache in development.
      if Rails.env.development? or not @@css_cache.include? path
        @@css_cache[path] =
          if defined? Hassle and Rails.configuration.middleware.include? Hassle
            file = path == :default ? '/stylesheets/email.css' : path
            File.read("#{Rails.root}/tmp/hassle#{file}")
          elsif Rails.configuration.try(:assets).try(:enabled)
            file = if path == :default
                     'email.css'
                   else
                     path.sub("#{Rails.configuration.assets.prefix}/", '')
                   end
            if asset = Rails.application.assets.find_asset(file)
              asset.body
            else
              raise "Couldn't find asset #{file} for premailer-rails3."
            end
          else
            file = path == :default ? '/stylesheets/email.css' : path
            File.read("#{Rails.root}/public#{file}")
          end
      end

      @@css_cache[path]
    rescue => ex
      # Print an error and store empty string as the CSS.
      puts ex.message
      @@css_cache[path] = ''
    end
  end
end
