require 'property_helpers'


module PropertyVisitorSpec
  describe PropertyVisitor do
    it_should_behave_like 'Property'

    it 'should reject empty properties' do
      p = Property.new(:p, [String]) { |a| }
      lambda { PropertyVisitor.new(p) }.should raise_error(RuntimeError)
    end

    it 'should ' do
      p = Property.new(:p, [TrueClass]) { |a| a }
      PropertyVisitor.new(p)
    end

    it '' do
      p = Property.new(:p, [String]) { |a| a.length == 0 }
      PropertyVisitor.new(p)
    end
  end
end
