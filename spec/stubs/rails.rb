require 'stubs/dummy'

module Logger
  extend self

  def try(*args); end
end

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

    module Assets
      extend self
    end

    def assets
      Assets
    end
  end

  def env
    Env
  end

  def configuration
    Configuration
  end

  def logger
    Logger
  end

  def public_path
    File.join(root, 'public')
  end

  def root
    'RAILS_ROOT'
  end

  def application
    Application
  end
end
