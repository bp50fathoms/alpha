require 'property'


module PropertyVisitorSpec
  describe PropertyVisitor do
    before(:each) do
      PropertyVisitor.reset
    end

    it 'should reject blocks with no args' do
      lambda do
        PropertyVisitor.accept(lambda { true })
      end.should raise_error(ArgumentError, 'arity 0 block')
    end

    it 'should reject empty blocks' do
      lambda do
        PropertyVisitor.accept(lambda { |a| })
      end.should raise_error(ArgumentError, 'empty block body')
    end

    it 'should add an instrumentation parameter for blocks of arity 1' do
      source(lambda { |a| a }).should ==
        'proc { |a, _r| _r.store(0, a) }'
    end

    it 'should add an instrumentation parameter for blocks of arity > 1' do
      source(lambda { |a,b| a }).should ==
        'proc { |a, b, _r| _r.store(0, a) }'
    end

    it 'should process correctly negation' do
      source(lambda { |a| not a }).should ==
        'proc { |a, _r| _r.store(1, (not _r.store(0, a))) }'
    end

    it 'should process correctly lazy conjunction' do
      source(lambda { |a,b| a && b }).should ==
        'proc { |a, b, _r| _r.store(2, (_r.store(0, a) and _r.store(1, b))) }'
    end

    it 'should process correctly lazy disjunction' do
      source(lambda { |a,b| a or b }).should ==
        'proc { |a, b, _r| _r.store(2, (_r.store(0, a) or _r.store(1, b))) }'
    end

    it 'should process correctly non-lazy conjunction' do
      source(lambda { |a,b| a & b }).should ==
        'proc { |a, b, _r| _r.store(2, _r.store(0, a).&(_r.store(1, b))) }'
    end

    it 'should process correctly non-lazy disjunction' do
      source(lambda { |a,b| a.|(b) }).should ==
        'proc { |a, b, _r| _r.store(2, _r.store(0, a).|(_r.store(1, b))) }'
    end

    it 'should process correctly equality' do
      source(lambda { |a,b| a == b }).should ==
        'proc { |a, b, _r| _r.store(2, (_r.store(0, a) == _r.store(1, b))) }'
    end

    it 'should process correctly inequality' do
      source(lambda { |a,b| a != b }).should ==
        "proc do |a, b, _r|\n" +
        "  _r.store(3, (not _r.store(2, (_r.store(0, a) == _r.store(1, b)))))\n" +
        'end'
    end

    it 'should process correctly universal quantification' do
      source(lambda { |a| a.all? { |e| e } }).should ==
        'proc { |a, _r| _r.store(1, a.all? { |e| _r.store(0, e) }) }'
    end

    it 'should process correctly existential quantification' do
      source(lambda { |a| a.any? { |e| e.a or e.b } }).should ==
        "proc do |a, _r|\n" +
        '  _r.store(3, a.any? { |e| ' +
        "_r.store(2, (_r.store(0, e.a) or _r.store(1, e.b))) })\n" +
        "end"
    end

    it 'should process correctly conditional expressions' do
      source(lambda { |a| a.b ? a.c : a.d }).should ==
        "proc do |a, _r|\n" +
        "  _r.store(3, _r.store(0, a.b) ? (_r.store(1, a.c)) " +
        ": (_r.store(2, a.d)))\n" +
        'end'
    end

    # implication and lazy implication

    # aritmetic comparisons

    # property composition

    # instance exec

    # begin end

    # big example 1

    def source(block)
      Ruby2Ruby.new.process(PropertyVisitor.accept(block).to_sexp)
    end
  end
end
