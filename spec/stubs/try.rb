class Object
  def try(method, *args)
    self.__send__(method, *args) rescue nil
  end
end
