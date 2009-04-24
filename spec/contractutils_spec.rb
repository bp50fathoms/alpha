require 'contract_utils'


module ContractUtilsSpec
  describe ContractUtils do
    it 'should call a method and return the result along with the old state' do
      a = [1,2,3]
      r = ContractUtils.send_with_old(a, :clear)
      a.should == []
      r.first.should == []
      r.last.should == [1,2,3]
    end
  end
end
