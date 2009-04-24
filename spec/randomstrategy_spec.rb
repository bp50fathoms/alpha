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


      describe RandomStrategy, 'with a contract that does not have any cases' do
        class Bar
          def bar
          end
        end

        def define_prop
          Contract.new(Bar.instance_method(:bar), []) do
            requires { true }
            ensures { |r| true }
          end
        end

        it_should_behave_like 'PropertyWithoutCases'
      end


      shared_examples_for 'ManyCases' do
        it 'should behave correctly when cases are generated' do
          100.times do
            check_generated(@strategy.generate)
            @strategy.exhausted?.should be_false
          end
          @strategy.progress.should == 1.0
        end
      end


      describe RandomStrategy, 'with a property that has many cases' do
        def define_prop
          property :p => [String, String] do |a,b| a == b end
        end

        it_should_behave_like 'PropertyWithCases'

        it_should_behave_like 'ManyCases'

        def check_generated(g)
          g.size.should == 2
          g.first.is_a?(String).should be_true
          g.last.is_a?(String).should be_true
        end
      end


      describe RandomStrategy, 'with a contract that has many cases' do
        class Foo
          def bar
            true
          end

          def self.arbitrary
            Foo.new
          end
        end

        def define_prop
          Contract.new(Foo.instance_method(:bar), []) do
            requires { true }
            ensures { |r| r == true }
          end
        end

        it_should_behave_like 'PropertyWithCases'

        it_should_behave_like 'ManyCases'

        def check_generated(g)
          g.size.should == 1
          g.first.is_a?(Foo).should be_true
        end
      end
    end
  end
end
