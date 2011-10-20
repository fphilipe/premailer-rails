require 'stubs/dummy'

module Rails
  extend self

  module Configuration
    extend self

    module Middleware
      extend self

      def include?(what)
        false
      end
    end

    def middleware
      Middleware
    end
  end

  module Env
    extend self

    def development?
      false
    end
  end

  module Application
    extend self

    def assets; end
  end

  def env
    Env
  end

  def configuration
    Configuration
  end

  def root
    'RAILS_ROOT'
  end

  def application
    Application
  end
end
