require 'forwardable'
require 'property'


class Property
  extend Forwardable

  attr_reader :key, :types

  def_delegator :types, :size, :arity

  def_delegator :predicate, :call

  def initialize(key, types, &block)
    raise ArgumentError, 'wrong key' unless key.is_a?(Symbol)
    raise ArgumentError, 'wrong type list' unless types.is_a?(Array)
    raise ArgumentError, 'a block must be provided' if block.nil?
    @key = key
    @types = types
    if block.arity > 0 or types.size == 0
      predicate(&block)
    else
      instance_eval(&block)
      raise ArgumentError, 'property predicate should be defined' if
        predicate.nil?
    end
    self.class[key] = self
  end

  def predicate(&expr)
    if expr.nil?
      @predicate
    else
      self.predicate = expr
    end
  end

  private

  def predicate=(expr)
    ts = types.size
    arity = expr.arity != -1 ? expr.arity : 0
    if ts != arity
      raise ArgumentError, "wrong number of types (#{ts} for #{arity})"
    end
    @predicate = expr
  end
end
