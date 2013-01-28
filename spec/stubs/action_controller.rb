# ActionController::Base.helpers.asset_path(file)
module ActionController
  module FakeHelpers
    def self.asset_path(file)
      'somewhere/on/the/disk/' + file
    end
  end

  module Base
    def self.helpers
      FakeHelpers
    end
  end
end