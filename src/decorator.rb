module Decorator
  def method_missing(name, *args)
    decorated.send(name, *args)
  end

  def respond_to?(name, include_private = false)
    decorated.respond_to?(name, include_private) ? true : super
  end
end
