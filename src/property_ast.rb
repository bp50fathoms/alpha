require 'initializer'
require 'visitable'


class UnaryExpr
  include Visitable
  attrs(:operator, :expr)
end

class BinaryExpr
  include Visitable
  attrs(:left_expr, :operator, :right_expr)
end

class QuantExpr
  include Visitable
  attrs(:type, :expr)
end

class Conditional
  include Visitable
  attrs(:condition, :then_branch, :else_branch)
end

class BoolAtom
  include Visitable
end
