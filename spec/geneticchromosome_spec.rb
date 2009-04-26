require 'genetic_chromosome'
require 'genetic_tleafs'
require 'pdecorator'
require 'property_helpers'


module GeneticChromosomeSpec
  describe ChromosomeFactory do

    it_should_behave_like 'Property'

    it '' do
      pr = property :p => [Fixnum, Fixnum] do |a,b|
        a >= b or b >= a
      end
      p = PropertyDecorator.new(pr)
      c = ChromosomeFactory.new(p, GeneticTreeLeafs.leafs(p.tree), [true, true])
      c1 = c.seed
      c1.fitness
      c.mutate(c1)
      c2 = c.seed
      c3 = c.reproduce(c1, c2)
      c.mutate(c3)
    end
  end
end
