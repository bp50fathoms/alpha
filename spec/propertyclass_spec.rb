require 'property_helpers'


module PropertyClassSpec
  describe Property do
    include PropertyHelpers

    it_should_behave_like 'Property'

    def declare_property_p
      Property.new(:p, [Object, Object]) do |a, b|
        a & b
      end
    end

    it 'should recognise a declared property' do
      p = declare_property_p
      Property.p(true, true).should be_true
      Property.p(true, false).should be_false
      Property.respond_to?(:p).should be_true
      Property[:p].should == p
    end

    it 'should not recognise an undeclared property' do
      lambda { Property.p }.should raise_error(NoMethodError)
      Property.respond_to?(:p).should be_false
      Property[:p].should be_nil
    end

    it 'should reject wrong argument number calls on properties' do
      p = declare_property_p
      lambda { Property.p(true) }.should raise_error(ArgumentError)
      Property[:p].should == p
    end

    it 'should assign correctly the documenting description through the writer' do
      Property.new(:p, [String]) do |a|
        a.length > 0
      end
      doc = 'Property for testing purposes'
      Property.new(:q, [Object, Object]) do |a, b|
        a & b
      end.desc = doc
      Property.new(:r, [Hash]) do |a|
        !a.nil?
      end
      Property[:p].desc.should be_nil
      Property[:q].desc.should == doc
      Property[:r].desc.should be_nil
    end

    it 'should assign correctly the documenting description through the global' do
      Property.new(:p, [String]) do |a|
        a.length > 0
      end
      doc = 'Property for testing purposes'
      Property.next_desc = doc
      Property.new(:q, [Object, Object]) do |a, b|
        a & b
      end
      Property.new(:r, [Hash]) do |a|
        !a.nil?
      end
      Property[:p].desc.should be_nil
      Property[:q].desc.should == doc
      Property[:r].desc.should be_nil
    end

    it 'should reject descriptions different than Strings' do
      lambda do
        declare_property_p.desc = 1
      end.should raise_error(ArgumentError, 'the description must be a String')
    end
  end
end
