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
    if ar(block) == 0 and types.size != 0
      instance_eval(&block)
      raise ArgumentError, 'predicate should be defined' if predicate.nil?
    else
      predicate(&block)
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
    elsif arity == 0 and args.length != 0
      raise ArgumentError, 'wrong number of arguments #{args.length} for 0'
    end
    predicate.call(*args)
  end

  private

  def predicate=(expr)
    ts = types.size
    aty = ar(expr)
    raise ArgumentError, 'varargs are unsupported' if aty < -1
    if ts != aty
      raise ArgumentError, "wrong number of types (#{ts} for #{aty})"
    end
    if aty == 0
      @predicate = expr
    else
      @predicate, @tree = PredicateVisitor.accept(expr)
      @cover_goal = Hash[*@tree.accept(CoverVisitor.instance, [true])]
    end
    @predicate
  end
end
