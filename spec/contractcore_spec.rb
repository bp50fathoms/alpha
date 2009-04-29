require 'property_helpers'
require 'contract'


module ContractSpec
  describe Contract do
    include PropertyHelpers

    it_should_behave_like 'Property'

    class Foo
      def bar(baz)
        Math.sqrt(baz)
      end
      def foobar; end
    end

    METHOD = Foo.instance_method(:bar)

    PRECONDITION = lambda { |n| n >= 0 }
    POSTCONDITION = lambda { |n,r| (r ** 2 - n).abs < 1e-5 }

    def contract
      Contract.new(METHOD, [Float], PRECONDITION, POSTCONDITION)
    end

    it 'should build a simple contract' do
      c = contract
      c.key.should == :'ContractSpec::Foo.bar'
      c.types.should == [ContractSpec::Foo, Float]
      c.method.should == METHOD
      c.precondition.should == PRECONDITION
      c.postcondition.should == POSTCONDITION
      c.call(Foo.new, 9).should be_true
      c.call(Foo.new, -1).should be_true
    end

    it 'should build a sandboxed contract' do
      c = Contract.new(METHOD, [Float]) do
        requires(&PRECONDITION)
        ensures(&POSTCONDITION)
      end
      c.key.should == :'ContractSpec::Foo.bar'
      c.types.should == [ContractSpec::Foo, Float]
      c.method.should == METHOD
      c.precondition.should == PRECONDITION
      c.postcondition.should == POSTCONDITION
      c.call(Foo.new, 5).should be_true
      c.call(Foo.new, -1).should be_true
    end

    it 'should build a sandboxed contract of a method of arity 0' do
      method = Foo.instance_method(:foobar)
      c = Contract.new(method, []) do
        requires { true }
        ensures { |r| r == nil }
      end
      c.call(Foo.new).should be_true
      c.call(Foo.new).should be_true
    end

    it 'should accept a ResultCollector explicitly as parameter' do
      c = contract
      c.call(Foo.new, 4, ResultCollector.new).should be_true
      c.call(Foo.new, -1, ResultCollector.new).should be_true
    end

    it 'should have instrumentation facilities working correctly' do
      c = contract
      r1 = ResultCollector.new
      c.call(Foo.new, 4, r1)
      r2 = ResultCollector.new
      c.call(Foo.new, -1, r2)
      ct = CoverTable.new(c)
      ct.add_result(r1)
      ct.add_result(r2)
      t = c.tree
      ct.table.should == { t => { true => 2 },
        t.condition => { true => 1, false => 1 },
        t.then_branch => { true => 1 } }
    end

    it 'should allow contracts for functions' do
      c = Contract.new(Math.method(:sqrt), [Float], PRECONDITION, POSTCONDITION)
      r1 = ResultCollector.new
      c.call(4, r1).should be_true
      c.call(-4, r1).should be_true
      ct = CoverTable.new(c)
      ct.add_result(r1)
      t = c.tree
      ct.table.should == { t => { true => 2 },
        t.condition => { true => 1, false => 1 },
        t.then_branch => { true => 1 } }
    end

    it 'should allow making assertions on the old state' do
      c = Contract.new(Array.instance_method(:clear), []) do
        requires { true }
        ensures { |r| r.old.size == 1 }
      end
      c.call([1], ResultCollector.new).should be_true
      c.call([3,4], ResultCollector.new).should be_false
    end

    it 'should reject a contract with mismatching type length' do
      lambda do
        Contract.new(METHOD, [], PRECONDITION, POSTCONDITION)
      end.should raise_error(ArgumentError)
    end

    it 'should reject a precondition with mismatching arity' do
      precondition = lambda { |n,r| true }
      lambda do
        Contract.new(METHOD, [Float], precondition, POSTCONDITION)
      end.should raise_error(ArgumentError)
    end

    it 'should reject a postcondition with mismatching arity' do
      precondition = lambda { |n,r| n >= 0 }
      postcondition = lambda { |n,r,s| }
      lambda do
        Contract.new(METHOD, [Float]) do
          requires(&precondition)
          ensures(&postcondition)
        end
      end.should raise_error(ArgumentError)
    end

    it 'should reject a contract without precondition' do
      lambda do
        Contract.new(METHOD, [Float]) do
          ensures(&POSTCONDITION)
        end
      end.should raise_error(Exception)
    end

    it 'should reject a contract without postcondition' do
      lambda do
        Contract.new(METHOD, [], PRECONDITION)
      end.should raise_error(ArgumentError)
    end
  end
end
