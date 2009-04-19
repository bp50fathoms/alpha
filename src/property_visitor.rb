require 'property'
require 'rubygems'
require 'ruby2ruby'
require 'parse_tree'
require 'parse_tree_extensions'


class PropertyVisitor
  def self.accept(block)
    sexp, tree = self.new.visit_body(block.to_sexp)
    ncode = Ruby2Ruby.new.process(sexp)
    newblock = block.binding.eval(ncode)
    [newblock, tree]
  end

  def visit(exp)
    send("visit_#{exp.first}", exp)
  end

  def visit_body(exp)
    raise ArgumentError, 'empty block body' unless exp[3]
    a = add_arg(exp[2])
    b, t = visit(exp[3])
    s = s(:iter, exp[1], a, b)
    [s, t]
  end

  def visit_lvar(exp)
    t = BoolAtom.new
    s = instrument(s(:lvar, exp[1]), t)
    [s, t]
  end

  def visit_call(exp)
    if [:&, :|, :==].include?(exp[2])
      b1, a1 = visit(exp[1])
      b2, a2 = visit(exp[3][1])
      op = { :& => :and, :| => :or, :== => :eql }
      t = BinaryExpr.new(a1, op[exp[2]], a2)
      s = instrument(s(:call, b1, exp[2], s(:arglist, b2)), t)
      [s, t]
    else
      t = BoolAtom.new
      s = instrument(exp, t)
      [s, t]
    end
  end

  def visit_iter(exp)
    if [:all?, :any?].include?(exp[1][2])
      b, a = visit(exp[3])
      op = { :all? => :all, :any? => :exist }
      t = QuantExpr.new(op[exp[1][2]], a)
      s = instrument(s(:iter,
                       s(:call, exp[1][1], exp[1][2], exp[1][3]),
                       exp[2], b), t)
      [s, t]
    else
      t = BoolAtom.new
      s = instrument(exp, t)
      [s, t]
    end
  end

  def visit_not(exp)
    b, a = visit(exp[1])
    t = UnaryExpr.new(:not, a)
    s = instrument(s(:not, b), t)
    [s, t]
  end

  def visit_and(exp)
    b_expr(exp, :and)
  end

  def visit_or(exp)
    b_expr(exp, :or)
  end

  def b_expr(exp, op)
    b1, a1 = visit(exp[1])
    b2, a2 = visit(exp[2])
    t = BinaryExpr.new(a1, op, a2)
    s = instrument(s(op, b1, b2), t)
    [s, t]
  end

  def visit_if(exp)
    b1, a1 = visit(exp[2])
    b2, a2 = visit(exp[3])
    c = BoolAtom.new
    t = Conditional.new(c , a1, a2)
    s = instrument(s(:if, instrument(exp[1], c), b1, b2), t)
    [s, t]
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

  def instrument(expr, o)
    s(:call,
      s(:call, nil, :_r, s(:arglist)),
      :store,
      s(:arglist,
        s(:call, s(:const, :ObjectSpace), :_id2ref,
          s(:arglist, s(:lit, o.object_id))),
        expr))
  end
end
