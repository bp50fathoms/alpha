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

    it 'should compute correctly the fitness for a simple property' do
      p = property :p => [Fixnum, Fixnum] do |a,b|
        a >= b or b >= a
      end
      chromosome(p, [true, true], [5, 10]).fitness.should == -5
      chromosome(p, [true, false], [5, 10]).fitness.should == -11
      chromosome(p, [false, true], [5, 10]).fitness.should == 0
      chromosome(p, [false, false], [5, 10]).fitness.should == -6
    end

    it 'should raise an exception when the property is falsified' do
      p = property :p => [Fixnum] do |a|
        a >= 3
      end
      lambda do
        chromosome(p, [true], [2]).fitness
      end.should raise_error(FalsifiedProperty)
      lambda do
        chromosome(p, [false], [2]).fitness
      end.should raise_error(FalsifiedProperty)
    end

    it 'should not crash when a subexpression is not evaluated' do
      p = property :p => [Fixnum, Fixnum] do |a,b|
        a >= b or b >= a
      end
      q = property :q => [Fixnum, Fixnum] do |a,b|
        (a >= b) | (b >= a)
      end
      chromosome(p, [true, true], [10, 5]).fitness.should == -GeneticFitness::MAXFIT
      chromosome(q, [true, true], [10, 5]).fitness.should == -5
    end

    it 'should handle correctly conditionals and atoms' do
      p = property :p => [Fixnum] do |a|
        a >= 0 ? a.odd? : a.even?
      end
      chromosome(p, [true, true, true], [1]).fitness.should ==
        -GeneticFitness::MAXFIT
    end

    def chromosome(property, goal, data)
      p = PropertyDecorator.new(property)
      c = ChromosomeFactory.new(p, goal)
      Chromosome.new(c, data)
    end
  end
end
