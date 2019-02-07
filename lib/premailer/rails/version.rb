# frozen_string_literal: true

class Premailer
  module Rails
    VERSION = File.read(
      File.expand_path('../../../../VERSION', __FILE__)
    ).strip.freeze
  end
end
