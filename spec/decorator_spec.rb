require 'decorator'
require 'initializer'


module DecoratorSpec
  describe Decorator do
    class Foo
      include Decorator
      attrs :decorated
    end

    it 'should forward correctly methods without arguments' do
      foo = Foo.new([1, 2, 3])
      foo.clear.should == []
      foo.decorated.should == []
    end

    it 'should forward correctly methods with arguments' do
      Foo.new(true) & false.should == false
      Foo.new(false) | true.should == true
    end

    it 'should respond to its methods and the ones of the decorated object' do
      foo = Foo.new(true)
      [:&, :|, :decorated].all? { |m| foo.respond_to?(m) }.should be_true
    end
  end
end
