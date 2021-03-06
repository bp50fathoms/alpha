require 'decorator'
require 'rubygems'
require 'parse_tree'
require 'parse_tree_extensions'
require 'ruby2ruby'
require 'unifiedarity'


class Contract
  def self.new(method, *args, &block)
    if method.is_a?(Method)
      FunctionPContract.new(method, *args, &block)
    else
      ObjectPContract.new(method, *args, &block)
    end
  end
end


class PContract < Property
  include UnifiedArity

  attr_reader :method, :precondition, :postcondition

  def initialize(method, types, precondition = nil, postcondition = nil, &block)
    raise ArgumentError, 'wrong method' if method.nil?
    raise ArgumentError, 'wrong type list' unless types.length == method.arity
    @method = method
    @precondition = precondition
    @postcondition = postcondition
    t = tl(method, types)
    @types = t
    instance_eval(&block) if block != nil
    check_arity(@precondition, 'precondition', method.arity)
    check_arity(@postcondition, 'postcondition', method.arity + 1)
    super("#{method.owner.name}.#{method.name}".to_sym, t,
          &build_predicate(t))
  end

  private

  def requires(&expr)
    @precondition = expr
  end

  def ensures(&expr)
    @postcondition = expr
  end

  def build_predicate(types)
    id = 'a'
    params = Array.new(types.length) { |i| p = id; id = id.next; p }
    pstr = params.inject('') { |i,e| i += e + ',' }[0..-2]
    predicate = eval pred_body(pstr)
  end

  def pred_body(pstr)
    pre = Ruby2Ruby.new.process(@precondition.to_sexp)[5..-1]
    post = Ruby2Ruby.new.process(@postcondition.to_sexp)[5..-1]
    params = pstr[2..-1]
    params2 = params + ',' if params
    params3 = ',' + params if params
    pred_str(pstr, params, pre, post, params2, params3)
     # "lambda { |#{pstr}| (a.instance_exec(#{params}) #{pre})" +
     #  "? (a.instance_exec(#{params2}CResult.new(ContractUtils.send_with_old(a," +
     #  "'#{@method.name}'#{params3}))) #{post}) : true}"
  end

  def check_arity(attr, element, exp_arity)
    raise ArgumentError, "wrong #{element} arity" if ar(attr) != exp_arity
  end
end


class ObjectPContract < PContract
  def initialize(*args, &block)
    super(*args, &block)
  end

  private

  def tl(method, types)
    [method.owner] + types
  end

  def pred_str(pstr, params, pre, post, params2, params3)
    "lambda { |#{pstr}| (a.instance_exec(#{params}) #{pre})" +
      "? (a.instance_exec(#{params2}CResult.new(ContractUtils.send_with_old(a," +
      "'#{@method.name}'#{params3}))) #{post}) : true}"
  end
end


class FunctionPContract < PContract
  def initialize(*args, &block)
    super(*args, &block)
  end

  private

  def tl(method, types)
    types
  end

  def pred_str(pstr, params, pre, post, params2, params3)
    "lambda { |#{pstr}| (self.instance_exec(#{pstr}) #{pre}) ? " +
      "(self.instance_exec(#{pstr}, #{@method.owner.to_s.match(/\:.*>/).to_s[1..-2]}"+      ".send('#{@method.name}', #{pstr})) #{post}) : true }"
  end
end


class CResult < TPDecorator
  attr_reader :old

  def initialize(r)
    super(r.first)
    @old = r.last
  end
end
