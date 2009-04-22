require 'forwardable'
require 'unifiedarity'


class Property
  extend Forwardable
  include UnifiedArity

  attr_reader :cover_goal, :key, :tree, :types

  def_delegator :types, :size, :arity

  def initialize(key, types, &block)
    raise ArgumentError, 'wrong key' unless key.is_a?(Symbol)
    raise ArgumentError, 'wrong type list' unless types.is_a?(Array)
    raise ArgumentError, 'a block must be provided' if block.nil?
    @key = key
    @types = types
    if ar(block) > 0 or ar(block) < -1 or types.size == 0
      predicate(&block)
    else
      instance_eval(&block)
      raise ArgumentError, 'predicate should be defined' if predicate.nil?
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

  def call(*args)
    if arity > 0 and args.length < predicate.arity
      args << ResultCollector.new
    end
    predicate.call(*args)
  end

  private

  def predicate=(expr)
    ts = types.size
    arity = ar(expr)
    raise ArgumentError, 'varargs are unsupported' if arity < -1
    if ts != arity
      raise ArgumentError, "wrong number of types (#{ts} for #{arity})"
    end
    if arity == 0
      @predicate = expr
    else
      @predicate, @tree = PredicateVisitor.accept(expr)
      @cover_goal = Hash[*@tree.accept(CoverVisitor.instance, [true])]
    end
    @predicate
  end
end
