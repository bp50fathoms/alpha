require 'genetic_tleafs'
require 'property_helpers'


module GeneticTreeLeafsSpec
  describe GeneticTreeLeafs do
    it 'should return all the leaf nodes for a simple property' do
      p = property :p => [Fixnum, Fixnum] do |a,b|
        a < b or true
      end
      t = p.tree
      l = GeneticTreeLeafs.leafs(t)
      l.should == [t.left_expr]
    end
  end
end
