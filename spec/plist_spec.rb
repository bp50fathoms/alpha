require 'pipeline'
require 'property_helpers'


module PListSpec
  describe PList do
    it_should_behave_like 'Property'

    def props
      property :a => [String] do |a|
        a.length > 0
      end

      property :b do
        true
      end
      [Property[:a], Property[:b]]
    end

    it 'should build a PList when using []' do
      pp = props
      pl = PList[*pp]
      check(pl, pp)
    end

    it 'should build a PList when using the constructor' do
      pp = props
      pl = PList.new(pp)
      check(pl, pp)
    end

    it 'should build a Plist with all defined Properties when required to do so' do
      pp = props
      pl = PList.all
      check(pl, pp)
    end

    it 'should filter elements correctly' do
      pp = props
      pl = PList.all.select { |e| e.arity > 0 }
      pl.class.should == PList
      check(pl, [pp[0]])
    end

    it 'should reject other elements than Property or PropertyDecorator instances' do
      lambda { PList[1] }.should raise_error(ArgumentError)
    end

    def check(pl, a)
      check_includes(pl, a)
      check_output(pl)
    end

    def check_includes(pl, a)
      pl.length.should == a.length
      pl.all? { |e| a.include?(e.property) }.should be_true
    end

    def check_output(pl)
      pl.output.should == pl
    end
  end
end
