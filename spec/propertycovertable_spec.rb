require 'property'


module CoverTableSpec
  describe CoverTable do
    shared_examples_for 'CoverTable' do
      before(:each) do
        @ct = CoverTable.new(coverage_goal)
      end

      after(:each) do
        @ct = nil
      end

      it 'should not add results that are not in the coverage goal' do
        t = @ct.table.clone
        s = rc({ 88 => [true, false], 132 => [1.0, 1.0] })
        @ct.add_result(s)
        @ct.table.should == t
      end

      def rc(table)
        stub('ResultCollector', :result => table)
      end
    end


    describe 'with a common coverage goal' do
      it_should_behave_like 'CoverTable'

      def coverage_goal
        { 1 => [true, false], 2 => [true], 3 => [false] }
      end

      it 'should have a cover factor of 0.0 initially' do
        @ct.cover_factor.should == 0.0
        @ct.covered?.should be_false
      end

      it 'should record results that are in the coverage goal' do
        s = rc({ 1 => [true, true], 2 => [true], 3 => [false] })
        @ct.add_result(s)
        @ct.cover_factor.should == 2 / 3.0
        @ct.covered?.should be_false
      end

      it 'should get ultimately covered' do
        s1 = rc({ 1 => [true, true], 2 => [true], 3 => [false] })
        @ct.add_result(s1)
        s2 = rc({ 1 => [false] })
        @ct.add_result(s2)
        @ct.cover_factor.should == 1.0
        @ct.covered?.should be_true
        s3 = rc({ 2 => [true], 3 => [false] })
        @ct.add_result(s3)
        @ct.cover_factor.should == 1.0
        @ct.covered?.should be_true
      end
    end

    describe 'with an empty coverage goal' do
      it_should_behave_like 'CoverTable'

      def coverage_goal; {} end

      it 'should be covered initially' do
        @ct.covered?.should be_true
        @ct.cover_factor.should == 1.0
      end
    end
  end
end
