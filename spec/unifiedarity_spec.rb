require 'unifiedarity'


module UnifiedAritySpec
  describe UnifiedArity do
    include UnifiedArity

    it 'should compute correctly the arity of blocks with no args' do
      UnifiedArity.ar(lambda { }).should == 0
    end

    it 'should compute correctly the arity of blocks with 0 args' do
      ar(lambda { || }).should == 0
    end

    it 'should compute correctly the arity of blocks with some args' do
      ar(lambda { |a| }).should == 1
    end

    it 'should compute correctly the arity of blocks with varargs' do
      ar(lambda { |a,*b| }).should == -2
    end
  end
end
