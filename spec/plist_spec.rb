require 'plist'
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

    it 'should build a PList when using []' # do
      # pp = props
      # pl = PList[*pp]
      # check_includes(pl, pp)
      # a = [1,2,3]
      # pl = PList[*a]
      # check_includes(pl, a)
      # check_output(pl)
    # end

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

    it 'filter to_plist'

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
