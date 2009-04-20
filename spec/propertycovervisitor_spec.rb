require 'property_helpers'


module CoverVisitorSpec
  describe CoverVisitor do
    it_should_behave_like 'Property'

    it 'should compute a correct coverage goal for an existentially q. property' do
      property :p => [Array] do |x|
        not x.any? { |e| p(e) and q(e) }
      end
      p = Property[:p]
      t = p.tree
      g = p.cover_goal
      g.should == { t => [true], t.expr => [false], t.expr.expr => [false],
                    t.expr.expr.left_expr => [true, false],
                    t.expr.expr.right_expr => [true, false] }
    end

    it 'should compute a correct coverage goal for a conditional property' do
      p = property :p => [String] do |x|
        if x.length < 2 then
          x.include?('a')
        else
          x.include?('abc')
        end
      end

      t = p.tree
      g = p.cover_goal
      g.should == { t => [true], t.condition => [true, false],
                    t.then_branch => [true], t.else_branch => [true] }
    end

    it 'should compute a correct coverage goal for a composed property' do
      p = property :p => [String] do |x|
        x.length == 0 or x == 'a'
      end

      q = property :q => [Array] do |x|
        !x.all? { |e| Property.p(e) }
      end

      t = q.tree
      t2 = p.tree
      g = q.cover_goal
      g.should == { t => [true], t.expr => [false], t2 => [false],
                    t2.left_expr => [false], t2.right_expr => [false] }
    end

    it 'should compute a correct coverage goal for true' do
      p = property(:p => [String]) { |x| true }
      p.cover_goal == {}
    end

    it 'should complain for some tautological properties (trivially false)' do
      lambda do
        p = property :p => [Array] do |x|
          not x.all? { |e| f(e) or true }
        end
      end.should raise_error(ArgumentError, 'property can be trivially falsified')
    end
  end
end
