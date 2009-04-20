require 'action'


module ActionSpec
  describe Action do
    include Action

    it 'should work correctly for initial actions' do
      a = [1, 2, 3]
      do! { a }.output.should == a
    end

    it 'should work correctly for intermediate actions' do
      (do! { [1, 2, 3] } | do! { |i| i.map { |e| e + 1 } }).output.should ==
        [2, 3, 4]
    end

    it 'should work with Procs of arity 0' do
      p = Proc.new { 1 }
      do!(&p).output.should == 1
    end

    it 'should work with lambdas of arity 0' do
      l = lambda { 2 }
      do!(&l).output.should == 2
    end

    it 'should work with Procs of arity 1' do
      p = Proc.new { |e| e + 1 }
      (do! { 3 } | do!(&p)).output.should == 4
    end

    it 'should work with lambdas of arity 1' do
      l = lambda { |e| e + 2 }
      (do! { 4 } | do!(&l)).output.should == 6
    end

    it 'should reject Procs of arity 2 or greater' do
      p = Proc.new { |x, y| }
      lambda { do!(&p) }.should raise_error(ArgumentError)
    end

    it 'should reject lambdas of arity 2 or greater' do
      l = lambda { |x, y, z, t| }
      lambda { do!(&l) }.should raise_error(ArgumentError)
    end
  end
end
