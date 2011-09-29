class Dummy
  def method_missing(m, *args)
    self.class.new
  end
end
