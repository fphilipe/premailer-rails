class Premailer
  module Rails
    module CSSLoaders
      module IgnoreLoader
        extend self

        def load(_url)
          ''
        end
      end
    end
  end
end
