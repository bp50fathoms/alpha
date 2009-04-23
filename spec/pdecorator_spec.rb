require 'pdecorator'


module PropertyDecoratorSpec
  describe PropertyDecorator do
    def prop
      property :p => [String] do |a|
        a.length >= 0
      end
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
