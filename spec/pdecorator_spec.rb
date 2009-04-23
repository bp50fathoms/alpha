require 'pdecorator'
require 'property_helpers'


module PropertyDecoratorSpec
  describe PropertyDecorator do
    it_should_behave_like 'Property'

    def prop
      property :p => [String] do |a|
        a.length >= 0
      end
    end

    it 'should be a decorator of property' do
      p = PropertyDecorator.new(prop)
      p.arity.should == 1
    end

    it 'should report that it is not falsified when there is no falsifying case' do
      p = PropertyDecorator.new(prop)
      p.falsifying_case.should be_nil
      p.falsified?.should be_false
    end

    it 'should report to be falsified when there is a falsifying case' do
      p = PropertyDecorator.new(prop)
      p.falsifying_case = 'a'
      p.falsified?.should be_true
    end
  end
end
