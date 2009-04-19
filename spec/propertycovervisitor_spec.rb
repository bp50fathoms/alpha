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
  end
end
