require 'property'


module PropertyVisitorSpec
  describe PropertyVisitor do
    it 'should reject empty blocks' do
      lambda do
        PropertyVisitor.proc(lambda { |a| })
      end.should raise_error(RuntimeError)
    end

    it 'should add an additional parameter for instrumentation' do
      source(PropertyVisitor.proc(lambda { |a| a })).should ==
        'proc { |a, _r| a }'
    end

    it 'should add an additional parameter for instrumentation' do
      source(PropertyVisitor.proc(lambda { |a,b| a & b })).should ==
        'proc { |a, b, _r| a.&(b) }'
    end

    def source(o)
      Ruby2Ruby.new.process(o.to_sexp)
    end
  end
end
