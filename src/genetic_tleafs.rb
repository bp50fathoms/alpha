require 'patternmatch'


module GeneticTreeLeafs
  def leafs(p)
    pmatch(p) do
      with(UnaryExpr) { leafs(p.expr) }
      with(BinaryExpr) { leafs(p.left_expr) + leafs(p.right_expr) }
      with(QuantExpr) { [p] }
      with(Conditional) do
        leafs(p.condition) + leafs(p.then_branch) + leafs(p.else_branch)
      end
      with(Composition) { leafs(Property[p.property].tree) }
      with(BoolConst) { [] }
      with(BoolAtom) { [p] }
    end
  end

  module_function :leafs
end
