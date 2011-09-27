module Dummy
  def method_missing(m, *args)
    self
  end
end
