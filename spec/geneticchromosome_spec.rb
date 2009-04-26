require 'genetic_chromosome'
require 'pdecorator'
require 'property_helpers'


module GeneticChromosomeSpec
  describe ChromosomeFactory do
    before(:each) do
      Property.clear
      pr = property :p => [Fixnum, Fixnum] do |a,b|
        a >= b or b >= a
      end
      @p = PropertyDecorator.new(pr)
      @c = ChromosomeFactory.new(@p, [true, false])
    end

    after(:each) do
      Property.clear
    end

    it 'should establish a correct goal' do
      @c.goal.should == { @p.tree.left_expr => true, @p.tree.right_expr => false }
    end

    it 'should seed adequate chromosomes' do
      100.times { check(@c.seed) }
    end

    it 'should mutate chromosomes correctly' do
      100.times { check(@c.mutate(@c.seed)) }
    end

    it 'should reproduce chromosomes correctly' do
      100.times do
        c1 = @c.seed
        c2 = @c.seed
        r = @c.reproduce(c1, c2)
        check(r)
        r.data.all? { |e| c1.data.include?(e) or c2.data.include?(e) }
      end
    end

    def check(c)
      c.data.length.should == 2
      c.data.all? { |e| e.is_a?(Fixnum) }.should be_true
    end
  end


  describe Chromosome do
    it_should_behave_like 'Property'
  end
end
