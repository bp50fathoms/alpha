require 'contract'
require 'rubygems'
require 'parse_tree'
require 'parse_tree_extensions'
require 'ruby2ruby'


class Contract < Property
  attr_reader :method, :precondition, :postcondition

  def initialize(method, types, precondition = nil, postcondition = nil, &block)
    raise ArgumentError, 'wrong method' if method.nil?
    raise ArgumentError, 'wrong type list' unless types.length == method.arity
    @method = method
    @precondition = precondition
    @postcondition = postcondition
    instance_eval(&block) if block != nil
    check_arity(@precondition, 'precondition', method.arity)
    check_arity(@postcondition, 'postcondition', method.arity + 1)
    t = [method.owner] + types
    super("#{method.owner.name}.#{method.name}".to_sym, t,
          &build_predicate(t))
  end

  def requires(&expr)
    @precondition = expr
  end

  def ensures(&expr)
    @postcondition = expr
  end

  private

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
    "lambda { |#{pstr}| (a.instance_exec(#{params}) #{pre})" +
      "? (a.instance_exec(#{params2}a.#{@method.name}(#{params})) #{post}) : true}"
  end


  def check_arity(attr, element, exp_arity)
    cond_arity = attr.arity != -1 ? attr.arity : 0
    raise ArgumentError, "wrong #{element} arity" if cond_arity != exp_arity
  end
end
