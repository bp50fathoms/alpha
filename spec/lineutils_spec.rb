require 'lineutils'


module LineUtilsSpec
  describe LineUtils do
    include LineUtils

    describe 'divide' do
      it 'should divide correctly when the word is larger than the word size' do
        divide('12345', 3).should == ['123' ,'45']
      end

      it 'should divide correctly when the word size is 1' do
        divide('1234', 1).should == ['1', '234']
      end

      it 'should divide correctly when the word size is equal to the word' do
        divide('1234567890', 10).should == ['1234567890', '']
      end

      it 'should divide correctly when the word is smaller than the word size' do
        divide('12345', 6).should == ['12345', '']
      end

      it 'should divide correctly the empty string' do
        divide('', 0).should == ['', '']
        divide('', 1).should == ['', '']
      end
    end


    describe 'full_wide' do
      it 'should widen correctly a short string' do
        full_wide('123', 4).should == '123 '
      end

      it 'should keep a string as it is when it is wide enough' do
        full_wide('123', 3).should == '123'
      end

      it 'should remove new lines' do
        full_wide("a\n", 3).should == 'a  '
      end

      it 'should remove new lines' do
        full_wide("\n", 3).should == ' ' * 3
      end

      it 'should remove new lines' do
        full_wide("aa\n", 3).should == 'aa '
      end

      it 'should not remove spaces' do
        full_wide(' a', 3).should == ' a '
      end

      it 'should reject long strings' do
        lambda { full_wide('aa', 1) }.should raise_error(ArgumentError)
      end
    end
  end
end
