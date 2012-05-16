module PremailerRails
  @config = {
    :generate_text_part => true
  }
  class << self
    attr_accessor :config
  end
end
