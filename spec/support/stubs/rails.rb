module Rails
  extend self

  def root
    @root ||= Pathname.new(".")
  end

  def logger
    @logger = Logger.new(STDOUT)
  end

  module Configuration
    extend self
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

  class Railtie
    class Configuration
      def after_initialize
        yield
      end
    end

    def self.config
      Configuration.new
    end
  end

  def env
    Env
  end

  def configuration
    Configuration
  end

  def application
    Application
  end
end
