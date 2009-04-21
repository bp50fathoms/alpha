require 'initializer'
require 'visitor'


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

class Composition
  include Visitable
  attrs(:property)
end

class BoolConst
  include Visitable
  attrs(:value)
end

class BoolAtom
  include Visitable
end
