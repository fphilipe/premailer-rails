module Rails
  extend self

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
