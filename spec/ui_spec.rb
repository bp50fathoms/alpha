require 'ui'


module UISpec
  describe UI do
    it 'should create a BatchUI when the output is specified' do
      UI.new(StringIO.new).class.should == BatchUI
    end

    it 'should not interfere with BatchUI#new' do
      BatchUI.new.class.should == BatchUI
    end
  end
end
