require 'property_helpers'


module PropertyCoreSpec
  describe Property do
    it_should_behave_like 'Property'

    it 'should build a property' do
      p = Property.new(:p, [String, String]) do |a,b|
        a + b == (b + a).reverse
      end
      p.key.should == :p
      p.types.should == [String, String]
      p.call('a', 'b').should be_true
    end

    it 'should build a sandboxed property' do
      p = Property.new(:p, [String]) do
        predicate { |a| a.length == a.size }
      end
      p.key.should == :p
      p.types.should == [String]
      p.call('aa').should be_true
    end

    it 'should accept a property with arity 0' do
      p = Property.new(:p, []) do
        1 > 0
      end
      p.key.should == :p
      p.types.should == []
      p.call.should be_true
    end

    it 'should accept a ResultCollector explicitly as parameter' do
      p = Property.new(:p, [String, String]) do |a,b|
        a + b == b + a
      end
      p.call('ab', 'ab', ResultCollector.new).should be_true
      p.call('a', 'b', ResultCollector.new).should be_false
    end

    it 'should reject a property with non-Symbol values as keys' do
      lambda { Property.new(1, []) { } }.should raise_error(ArgumentError)
      lambda do
        Property.new(1, String) { |a| a.size == 0 }
      end.should raise_error(ArgumentError)
    end

    it 'should reject a property without a type list' do
      lambda do
        Property.new(:a, String) { |e| }
      end.should raise_error(ArgumentError)
      lambda { Property.new(:b, nil) { |e| } }.should raise_error(ArgumentError)
    end

    it 'should reject a property without a block' do
      lambda { Property.new(:p) }.should raise_error(ArgumentError)
    end

    it 'should reject a property without a defined predicate' do
      lambda { Property.new(:p, [String]) {} }.should raise_error(ArgumentError)
    end

    it 'should reject a property with varargs' do
      lambda do
        Property.new(:p, [String]) { |a,*b| }
      end.should raise_error(ArgumentError, 'varargs are unsupported')
    end

    it 'should reject a sandboxed property with varargs' do
      lambda do
        Property.new(:p, [String, String]) do |a,*b|
        end
      end.should raise_error(ArgumentError, 'varargs are unsupported')
    end

    it 'should reject a property with mismatching arity' do
      lambda do
        Property.new(:p, [String]) do |a,b|
          a + b == (b + a).reverse
        end
      end.should raise_error(ArgumentError)
    end

    it 'should reject a sandboxed property with mismatching arity' do
      lambda do
        Property.new(:p, [String]) do |a, b|
          predicate { |a, b| a + b == (b + a).reverse }
        end
      end.should raise_error(ArgumentError)
    end
  end
end
