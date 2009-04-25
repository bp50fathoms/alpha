require 'genetic_fitness'


module GeneticFitnessSpec
  describe GeneticFitness do
    include GeneticFitness

    it 'should compute correctly the fitness for <' do
      fitness(:<, true, 0, 2).should == 0
      fitness(:<, true, 1, 2).should == 0
      fitness(:<, true, 2, 2).should == 1
      fitness(:<, true, 3, 2).should == 2
      fitness(:<, true, 4, 2).should == 3
      fitness(:<, false, 0, 2).should == 2
      fitness(:<, false, 1, 2).should == 1
      fitness(:<, false, 2, 2).should == 0
      fitness(:<, false, 3, 2).should == 0
    end

    it 'should compute correctly the fitness for <=' do
      fitness(:<=, true, 0, 2).should == 0
      fitness(:<=, true, 1, 2).should == 0
      fitness(:<=, true, 2, 2).should == 0
      fitness(:<=, true, 3, 2).should == 1
      fitness(:<=, true, 4, 2).should == 2
      fitness(:<=, false, 0, 2).should == 3
      fitness(:<=, false, 1, 2).should == 2
      fitness(:<=, false, 2, 2).should == 1
    end

    it 'should compute correctly the fitness for ==' do
      fitness(:==, true, 0, 0).should == 0
    end

    it 'should compute correctly the fitness for an atom' do
      fitness(:atom, true, true).should == 0
      fitness(:atom, true, false).should == GeneticFitness::MAXFIT
      fitness(:atom, false, true).should == GeneticFitness::MAXFIT
      fitness(:atom, false, false).should == 0
    end

    it 'should compute correctly the fitness for >' do
      fitness(:>, true, 3, 2).should == 0
    end

    it 'should compute correctly the fitness for >=' do
      fitness(:>=, true, 2, 2).should == 0
    end
  end
end
