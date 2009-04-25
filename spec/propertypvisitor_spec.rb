require 'property'


module PredicateVisitorSpec
  describe PredicateVisitor do
    it 'should reject blocks with no args' do
      lambda do
        accept { true }
      end.should raise_error(ArgumentError, 'arity 0 block')
    end

    it 'should reject empty blocks' do
      lambda do
        accept { |a| }
      end.should raise_error(ArgumentError, 'empty block body')
    end

    it 'should add an instrumentation parameter for blocks of arity 1' do
      b, t = accept { |a| a }
      source(b).should == "proc { |a, _r| _r.store(#{id(t)}, a) }"
    end

    it 'should add an instrumentation parameter for blocks of arity > 1' do
      b, t = accept { |a,b| a }
      source(b).should == "proc { |a, b, _r| _r.store(#{id(t)}, a) }"
    end

    it 'should reject properties containing non-expression statements gracefully' do
      lambda do
        accept do |a|
          while true
          end
        end
      end.should raise_error(ArgumentError, 'block containing unsupported elements')
    end

    it 'should process correctly Boolean literals (true)' do
      b, t = accept { |a| true }
      source(b).should == 'proc { |a, _r| true }'
    end

    it 'should process correctly Boolean literals (false)' do
      b, t = accept { |a| a or false }
      source(b).should ==
        "proc do |a, _r|\n" +
        "  _r.store(#{id(t)}, (_r.store(#{id(t.left_expr)}, a) or false))\n" +
        'end'
    end

    it 'should process correctly negation' do
      b, t = accept { |a| not a }
      source(b).should ==
        "proc do |a, _r|\n" +
        "  _r.store(#{id(t)}, (not _r.store(#{id(t.expr)}, a)))\n" +
        'end'
    end

    it 'should process correctly lazy conjunction' do
      b, t = accept { |a,b| a && b }
      source(b).should ==
        "proc do |a, b, _r|\n" +
        "  _r.store(#{id(t)}, (_r.store(#{id(t.left_expr)}, a)" +
        " and _r.store(#{id(t.right_expr)}, b)))\n" +
        'end'
    end

    it 'should process correctly lazy disjunction' do
      b, t = accept { |a,b| a or b }
      source(b).should ==
        "proc do |a, b, _r|\n" +
        "  _r.store(#{id(t)}, (_r.store(#{id(t.left_expr)}, a)" +
        " or _r.store(#{id(t.right_expr)}, b)))\n" +
        'end'
    end

    it 'should process correctly non-lazy conjunction' do
      b, t = accept { |a,b| a & b }
      source(b).should ==
        "proc do |a, b, _r|\n" +
        "  _r.store(#{id(t)}, _r.store(#{id(t.left_expr)}, a)" +
        ".&(_r.store(#{id(t.right_expr)}, b)))\n" +
        'end'
    end

    it 'should process correctly non-lazy disjunction' do
      b, t = accept { |a,b| a.|(b) }
      source(b).should ==
        "proc do |a, b, _r|\n" +
        "  _r.store(#{id(t)}, _r.store(#{id(t.left_expr)}, a)" +
        ".|(_r.store(#{id(t.right_expr)}, b)))\n" +
        'end'
    end

    it 'should process correctly universal quantification' do
      b, t = accept { |a| a.all? { |e| e } }
      source(b).should ==
        "proc do |a, _r|\n" +
        "  _r.store(#{id(t)}, a.all? { |e| _r.store(#{id(t.expr)}, e) })\n" +
        'end'
    end

    it 'should process correctly existential quantification' do
      b, t = accept { |a| a.any? { |e| e.a or e.b } }
      source(b).should ==
        "proc do |a, _r|\n" +
        "  _r.store(#{id(t)}, a.any? do |e|\n" +
        "    _r.store(#{id(t.expr)}, (_r.store(#{id(t.expr.left_expr)}, e.a) " +
        "or _r.store(#{id(t.expr.right_expr)}, e.b)))\n" +
        "  end)\n" +
        'end'
    end

    it 'should process correctly conditional expressions' do
      b, t = accept { |a| a.b ? a.c : a.d }
      source(b).should ==
        "proc do |a, _r|\n" +
        "  _r.store(#{id(t)}, if _r.store(#{id(t.condition)}, a.b) then\n" +
        "    _r.store(#{id(t.then_branch)}, a.c)\n" +
        "  else\n    _r.store(#{id(t.else_branch)}, a.d)\n  end)\n" +
        'end'
    end

    it 'should process correctly property composition' do
      b, t = accept { |a| f(a) and Property.b(a) }
      source(b).should ==
        "proc do |a, _r|\n" +
        "  _r.store(#{id(t)}, (_r.store(#{id(t.left_expr)}, f(a)) " +
        "and _r.store(#{id(t.right_expr)}, Property.b(a, _r))))\n" +
        'end'
    end

    it 'should process correctly instance_exec' do
      b, t = accept { |a| a.instance_exec(1,2) { |c,d| f(c + d) } }
      source(b).should ==
        "proc do |a, _r|\n" +
        "  a.instance_exec(1, 2) do |c, d|\n" +
        "    _r.store(#{id(t)}, f((c + d)))\n" +
        "  end\n" +
        'end'
    end

    it 'should not process unknown method calls and blocks' do
      b, t = accept { |a, b| q(a && b) or r { a } }
      source(b).should ==
        "proc do |a, b, _r|\n" +
        "  _r.store(#{id(t)}, (_r.store(#{id(t.left_expr)}, q((a and b))) or " +
        "_r.store(#{id(t.right_expr)}, r { a })))\n" +
        'end'
    end

    it 'should process correctly arithmetic comparisons' do
      b, t = accept { |a,b,c,d| (a + b) <= c and d }
      source(b).should ==
        "proc do |a, b, c, d, _r|\n" +
        "  _r.store(#{id(t)}, (_r.store(#{id(t.left_expr)}, " +
        "(_r.store(#{id(t.left_expr.comp.left_expr)}, (a + b)) " +
        "<= _r.store(#{id(t.left_expr.comp.right_expr)}, c)))" +
        " and _r.store(#{id(t.right_expr)}, d)))\n" +
        'end'
    end

    def accept(&block)
      PredicateVisitor.accept(block)
    end

    def source(block)
      Ruby2Ruby.new.process(block.to_sexp)
    end

    def id(o)
      "ObjectSpace._id2ref(#{o.object_id})"
    end
  end
end


# it 'should process correctly inequality' do
#   b, t = accept { |a,b| a != b }
#   source(b).should ==
#     "proc do |a, b, _r|\n" +
#     "  _r.store(#{id(t)}, (not _r.store(#{id(t.expr)}, " +
#     "(_r.store(#{id(t.expr.left_expr)}, a) " +
#     "== _r.store(#{id(t.expr.right_expr)}, b)))))\n" +
#     'end'
# end

# it 'should process correctly equality' do
#   b, t = accept { |a,b| a == b }
#   source(b).should ==
#     "proc do |a, b, _r|\n" +
#     "  _r.store(#{id(t)}, (_r.store(#{id(t.left_expr)}, a) " +
#     "== _r.store(#{id(t.right_expr)}, b)))\n" +
#     'end'
# end


# it 'should process correctly lazy implication' # do
#   b, t = accept { |a,b| a.l_implies { b }
# end

# it 'should process correctly non-lazy implication'#  do
#   b, t = accept { |a,b| a.implies b }
#   source(b).should ==
#     "proc do |a, b, _r|\n" +
#     "  _r.store(#{id(t)}, _r.store(#{id(t.left_expr)}, a)" +
#     ".implies(_r.store(#{id(t.right_expr)}, b)))\n" +
#     'end'
# end
