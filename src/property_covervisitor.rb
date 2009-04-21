require 'singleton'
require 'visitor'


class CoverVisitor
  include Singleton

  T = {
    :and => {
      true => [true],
      false => [true, false] },

    :or => {
      true => [true, false],
      false => [false] },

    :not => {
      true => [false],
      false => [true] },

    :all => {
      true => [true],
      false => [true, false] },

    :exist => {
      true => [true, false],
      false => [false] }
  }


  def visit_boolatom(e, v)
    [e, v]
  end

  def visit_boolconst(e, v)
    unless v.include?(e.value)
      raise ArgumentError, 'property can be trivially falsified'
    end
    []
  end

  def visit_unaryexpr(e, v)
    sub = m(:not, v)
    [e, v] + visit(e.expr, sub)
  end

  def visit_binaryexpr(e, v)
    sub = m(e.operator, v)
    [e, v] + visit(e.left_expr, sub) + visit(e.right_expr, sub)
  end

  def visit_quantexpr(e, v)
    sub = m(e.type, v)
    [e, v] + visit(e.expr, sub)
  end

  def visit_conditional(e, v)
    [e, v] + visit(e.condition, [true, false]) + visit(e.then_branch, v) +
      visit(e.else_branch, v)
  end

  def visit_composition(e, v)
    raise ArgumentError, "unknown property #{e.property}" unless Property[e.property]
    visit(Property[e.property].tree, v)
  end

  private

  def m(op, v)
    v.map { |e| T[op][e] }.flatten.uniq
  end

  include Visit
end
