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

    it 'should build a simple contract' do
      precondition = lambda { |n| n >= 0 }
      postcondition = lambda { |n,r| (r ** 2 - n).abs < 1e-5 }
      c = Contract.new(METHOD, [Float], precondition, postcondition)
      c.key.should == :'ContractSpec::Foo.bar'
      c.types.should == [ContractSpec::Foo, Float]
      c.method.should == METHOD
      c.precondition.should == precondition
      c.postcondition.should == postcondition
      c.call(Foo.new, 1).should be_true
      c.call(Foo.new, -1).should be_true
    end

    it 'should build a complex contract' do
      precondition = lambda { |n| n >= 0 }
      postcondition = lambda { |n,r| (r ** 2 - n).abs < 1e-5 }
      c = Contract.new(METHOD, [Float]) do
        requires(&precondition)
        ensures(&postcondition)
      end
      c.key.should == :'ContractSpec::Foo.bar'
      c.types.should == [ContractSpec::Foo, Float]
      c.method.should == METHOD
      c.precondition.should == precondition
      c.postcondition.should == postcondition
    end

    it 'should build a complex contract of a method of arity 0' do
      method = Foo.instance_method(:foobar)
      c = Contract.new(method, []) do
        requires { }
        ensures { |r| r == nil }
      end
    end

    it 'should reject a contract with mismatching type length' do
      precondition = lambda { |n| n >= 0 }
      postcondition = lambda { |n,r| (r ** 2 - n).abs < 1e-5 }
      lambda do
        Contract.new(METHOD, [], precondition, postcondition)
      end.should raise_error(ArgumentError)
    end

    it 'should reject a precondition with mismatching arity' do
      precondition = lambda { |n,r| }
      postcondition = lambda { |n,r| (r ** 2 - n).abs < 1e-5 }
      lambda do
        Contract.new(METHOD, [Float], precondition, postcondition)
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
      postcondition = lambda { |n,r| (r ** 2 - n).abs < 1e-5 }
      lambda do
        Contract.new(METHOD, [Float]) do
          ensures(&postcondition)
        end
      end.should raise_error(Exception)
    end

    it 'should reject a contract without postcondition' do
      precondition = lambda { |n,r| n >= 0 }
      lambda do
        Contract.new(METHOD, [], precondition)
      end.should raise_error(ArgumentError)
    end
  end
end
