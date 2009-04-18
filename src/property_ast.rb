require 'initializer'
require 'visitable'


class ASTNode; include Visitable; end
class UnaryExpr < ASTNode; end
class BinaryExpr < ASTNode; end
class Conditional < ASTNode; end
class BoolAtom < ASTNode; end
