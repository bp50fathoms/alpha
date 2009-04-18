require 'initializer'
require 'visitable'

def attrp(*params)
  attr_accessor *initsuper_with(params, [:key])
end

class ASTNode; include Visitable; attrs(:key) end
class UnaryExpr < ASTNode; attrp(:operator, :expr) end
class BinaryExpr < ASTNode; attrp(:left_expr, :operator, :right_expr) end
class Conditional < ASTNode; attrp(:condition, :then_branch, :else_branch) end
class BoolAtom < ASTNode; attrp end
