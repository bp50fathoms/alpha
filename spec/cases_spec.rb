require 'cases'
require 'property'
require 'strategy_helpers'


module CasesSpec
  describe CasesStrategy do
    def strategy; CasesStrategy end

    describe CasesStrategy, 'when just built' do
      include StrategyHelpers

      it_should_behave_like 'NewStrategy'
    end


    describe CasesStrategy do
      it_should_behave_like 'Strategy'

      describe CasesStrategy, 'with a property that does not have any' do
        def define_prop
          property :p => [String] do |e|
            e.length > 1
          end
        end

        it_should_behave_like 'PropertyWithoutCases'
      end


      describe CasesStrategy, 'with a property that has one case' do
        def define_prop
          property :p => String do
            predicate { |s| s.length >= 0 }

            always_check ''
          end
        end

        it_should_behave_like 'PropertyWithCases'

        it 'should behave correctly when one case is generated' do
          @strategy.generate.should == ['']
          @strategy.exhausted?.should be_true
          @strategy.progress.should == 1
          lambda { @strategy.generate }.should raise_error
        end
      end


      describe CasesStrategy, 'with a property that has many cases' do
        def define_prop
          property :q => [String, String] do
            predicate { |s, t| s == t }

            always_check ['', ''], ['a', 'a'], ['b', 'b']
          end
        end

        it_should_behave_like 'PropertyWithCases'

        it 'should behave correctly when cases are generated' do
          @strategy.generate.should == ['', '']
          @strategy.exhausted?.should be_false
          @strategy.progress.should == 1.0/3
          @strategy.generate.should == ['a', 'a']
          @strategy.exhausted?.should be_false
          @strategy.progress.should == 2.0/3
          @strategy.generate.should == ['b', 'b']
          @strategy.exhausted?.should be_true
          @strategy.progress.should == 3/3
          lambda { @strategy.generate }.should raise_error
        end
      end
    end
  end
end
