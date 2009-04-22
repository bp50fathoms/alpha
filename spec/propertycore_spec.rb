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

    it 'should accept a degenerate property (with arity 0)' do
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

    it 'should have instrumentation facilities working correctly' do
      p = property :p => [String] do |a|
        if a.length > 0
          a.length > 0
        else
          a.length == 0
        end
      end
      r1 = ResultCollector.new
      p.call('a', r1)
      r2 = ResultCollector.new
      p.call('', r2)
      c = CoverTable.new(p.cover_goal)
      c.add_result(r1)
      c.add_result(r2)
      t = p.tree
      c.table.should == { t => { true => 2 },
        t.condition => { true => 1, false => 1 },
        t.then_branch => { true => 1 },
        t.else_branch => { true => 1 } }
    end

    it 'should reject extreme varargs blocks that are incorrect in Proc' do
      lambda do
        p = property :p do |*a|
          true
        end
      end.should raise_error(ArgumentError)
    end

    it 'should reject being called with less than 1 arg minus its arity' do
      p = property :p => [String] do |a|
        a.length > 0
      end
      p.call('a').should be_true
      p.call('abc', ResultCollector.new).should be_true
      lambda { p.call }.should raise_error(ArgumentError)
    end

    it 'should reject being called with args different than arity in case its
    degenerated' do
      p = property :p do
        true
      end
      p.call
      lambda { p.call(1) }.should raise_error(ArgumentError)
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
