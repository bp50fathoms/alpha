require 'forwardable'


module Decorator
  def method_missing(name, *args)
    decorated.send(name, *args)
  end

  def respond_to?(name, include_private = false)
    decorated.respond_to?(name, include_private) ? true : super
  end
end


class TPDecorator
  extend Forwardable
  include Decorator

  attr_reader :decorated

  def initialize(decorated)
    @decorated = decorated
  end

  def_delegators :@decorated, *(Object.instance_methods - ['method_missing',
                                                           '__id__', '__send__'])
end
