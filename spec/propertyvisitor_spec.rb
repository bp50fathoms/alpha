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
      source(PropertyVisitor.accept(lambda { |a| a })).should ==
        'proc { |a, _r| _r.store(0, a) }'
    end

    it 'should add an additional parameter for instrumentation with > 1 argument' do
      source(PropertyVisitor.accept(lambda { |a,b| a & b })).should ==
        'proc { |a, b, _r| _r.store(2, _r.store(0, a).&(_r.store(1, b))) }'
    end

    def source(o)
      Ruby2Ruby.new.process(o.to_sexp)
    end
  end
end
