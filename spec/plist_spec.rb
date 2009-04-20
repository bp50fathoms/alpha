require 'plist'


module PListSpec
  describe PList do
    it 'should build a PList when using []' do
      a = [1,2,3]
      pl = PList[*a]
      check_includes(pl, a)
      check_output(pl)
    end

    it 'should build a PList when using the constructor' do
      a = [3,4,5]
      pl = PList.new(a)
      check_includes(pl, a)
      check_output(pl)
    end

    def check_includes(pl, a)
      a.all? { |e| pl.include?(e) }.should be_true
    end

    def check_output(pl)
      pl.output.should == pl
    end
  end
end
