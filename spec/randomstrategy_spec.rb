require 'property'
require 'random'
require 'strategy_helpers'


module RandomStrategySpec
  describe RandomStrategy do
    def strategy; RandomStrategy end


    describe RandomStrategy, 'when just built' do
      include StrategyHelpers

      it_should_behave_like 'NewStrategy'
    end


    describe RandomStrategy do
      it_should_behave_like 'Strategy'


      describe RandomStrategy, 'with a property that does not have any cases' do
        def define_prop
          property :p => [String, Range] do |a, b| a == b end
        end

        it_should_behave_like 'PropertyWithoutCases'
      end


      describe RandomStrategy, 'with a property that has many cases' do
        def define_prop
          property :p => [String, String] do |a,b| a == b end
        end

        it_should_behave_like 'PropertyWithCases'

        it 'should behave correctly when cases are generated' do
          100.times do
            check_generated(@strategy.generate)
            @strategy.exhausted?.should be_false
          end
          @strategy.progress.should == 1.0
        end

        def check_generated(g)
          g.size.should == 2
          g.first.is_a?(String).should be_true
          g.last.is_a?(String).should be_true
        end
      end
    end
  end
end
