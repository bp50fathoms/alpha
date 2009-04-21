require 'progressbar'


module ProgressBarSpec
  shared_examples_for 'ProgressBar' do
    before(:each) do
      @pb = pb
    end

    after(:each) do
      @pb = nil
    end
  end


  describe ProgressBar do
    it_should_behave_like 'ProgressBar'

    def pb; ProgressBar.new(5, 3) end

    it 'should be empty initially' do
      @pb.to_str.should == '[>  ] 0/5'
      @pb.full?.should be_false
    end

    it 'should progress adequately' do
      3.times { @pb.step }
      @pb.to_str.should == '[=> ] 3/5'
      @pb.full?.should be_false
    end

    it 'should not be full until the total has been reached' do
      4.times { @pb.step }
      @pb.to_str.should == '[==>] 4/5'
      @pb.full?.should be_false
    end

    it 'should be full when the total has been reached' do
      5.times { @pb.step }
      @pb.to_str.should == '[===] 5/5'
      @pb.full?.should be_true
    end

    it 'should reject stepping over the total' do
      lambda do
        6.times { @pb.step }
      end.should raise_error(RuntimeError)
    end
  end


  describe ProgressBar, 'prime number example' do
    it_should_behave_like 'ProgressBar'

    def pb; ProgressBar.new(101, 3) end

    it 'should not be full until the total has been reached' do
      @pb.to_str.should == '[>  ]   0/101'
      100.times do
        @pb.step
        @pb.to_str.include?('[===]').should be_false
      end
    end

    it 'should be full when the total has been reached' do
      101.times { @pb.step }
      @pb.to_str.should == '[===] 101/101'
    end
  end
end
