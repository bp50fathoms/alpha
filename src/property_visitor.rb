require 'property'
require 'rubygems'
require 'ruby2ruby'
require 'parse_tree'
require 'parse_tree_extensions'


class PropertyVisitor
  @@count = 0

  def self.reset
    @@count = 0
  end

  def self.accept(block)
    ncode = Ruby2Ruby.new.process(self.new.visit_body(block.to_sexp))
    block.binding.eval(ncode)
  end

  def visit(exp)
    send("visit_#{exp.first}", exp)
  end

  def visit_body(exp)
    raise ArgumentError, 'empty block body' unless exp[3]
    s(:iter, exp[1], add_arg(exp[2]), visit(exp[3]))
  end

  def visit_lvar(exp)
    instrument(s(:lvar, exp[1]))
  end

  def visit_call(exp)
    if [:&, :|].include?(exp[2])
      instrument(s(:call, visit(exp[1]), exp[2], s(:arglist, visit(exp[3][1]))))
    else
      exp
    end
  end

  def visit_not(exp)
    instrument(s(:not, visit(exp[1])))
  end

  def visit_and(exp)
    instrument(s(:and, visit(exp[1]), visit(exp[2])))
  end

  def visit_or(exp)
    instrument(s(:or, visit(exp[1]), visit(exp[2])))
  end

  def visit_if(exp)
    s(:if, instrument(exp[1]), visit(exp[2]), visit(exp[3]))
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
