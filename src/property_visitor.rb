require 'property'
require 'rubygems'
require 'ruby2ruby'
require 'parse_tree'
require 'parse_tree_extensions'


class PropertyVisitor < SexpProcessor
  @@count = 0

  def self.reset
    @@count = 0
  end

  def self.proc(block)
    ncode = Ruby2Ruby.new.process(self.new.proc_body(block.to_sexp))
    block.binding.eval(ncode)
  end

  def proc_body(exp)
    exp.shift
    call = exp.shift
    asgn = exp.shift
    raise ArgumentError, 'empty block body' if exp.empty?
    s(:iter, call, add_arg(asgn), process(exp.shift))
  end

  def process_lvar(exp)
    exp.shift
    var = exp.shift
    instrument(s(:lvar, var))
  end

  def process_call(exp)
    exp.shift
    lvalue = process(exp.shift)
    method = exp.shift
    arglist = exp.shift
    instrument(s(:call, lvalue, method, s(:arglist, process(arglist[1]))))
  end

  private

  def add_arg(asgn)
    raise ArgumentError, 'arity 0 block' unless asgn
    param = s(:lasgn, :_r)
    if asgn[0] == :lasgn
      s(:masgn, s(:array, asgn, param))
    else
      asgn[1] << param
      asgn
    end
  end

  def instrument(expr)
    s = s(:call,
          s(:call, nil, :_r, s(:arglist)),
          :store,
          s(:arglist, s(:lit, @@count), expr))
    @@count += 1
    s
  end
end
