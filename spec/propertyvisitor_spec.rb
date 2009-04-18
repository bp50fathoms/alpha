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

    it 'should add an additional parameter for instrumentation with 1 argument' do
      source(lambda { |a| a }).should ==
        'proc { |a, _r| _r.store(0, a) }'
    end

    it 'should add an additional parameter for instrumentation with > 1 argument' do
      source(lambda { |a,b| a & b }).should ==
        'proc { |a, b, _r| _r.store(2, _r.store(0, a).&(_r.store(1, b))) }'
    end

    it 'should process correctly not' do
      source(lambda { |a| not a }).should ==
        'proc { |a, _r| _r.store(1, (not _r.store(0, a))) }'
    end

    it 'should process correctly lazy and' do
      source(lambda { |a, b| a && b }).should ==
        'proc { |a, b, _r| _r.store(2, (_r.store(0, a) and _r.store(1, b))) }'
    end

    it 'should process correctly lazy or' do
      source(lambda { |a, b| a or b }).should ==
        'proc { |a, b, _r| _r.store(2, (_r.store(0, a) or _r.store(1, b))) }'
    end

    it 'should treat correctly unary methods'

    it 'should process all?'

    it 'should process any?'

    def source(block)
      Ruby2Ruby.new.process(PropertyVisitor.accept(block).to_sexp)
    end
  end
end
