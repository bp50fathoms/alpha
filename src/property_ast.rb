require 'initializer'
require 'visitor'


def attrd(*params, &rest)
  attr_reader *initialize_with(*params, &rest)
end

class UnaryExpr
  include Visitable
  attrd(:operator, :expr)
end

class BinaryExpr
  include Visitable
  attrd(:left_expr, :operator, :right_expr)
end

class QuantExpr
  include Visitable
  attrd(:type, :expr)
end

class Conditional
  include Visitable
  attrd(:condition, :then_branch, :else_branch)
end

class Composition
  include Visitable
  attrd(:property)
end

class BoolConst
  include Visitable
  attrd(:value)
end

class BoolAtom
  include Visitable
  attrd(:code)
end
