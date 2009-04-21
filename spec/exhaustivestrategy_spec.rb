require 'exhaustive'
require 'property'
require 'strategy_helpers'


module ExhaustiveStrategySpec
  describe ExhaustiveStrategy do
    def strategy; ExhaustiveStrategy end

    describe ExhaustiveStrategy, 'when just built' do
      include StrategyHelpers

      it_should_behave_like 'NewStrategy'
    end


    describe ExhaustiveStrategy do
      it_should_behave_like 'Strategy'


      describe ExhaustiveStrategy, 'with a property that does not have any cases' do
        def define_prop
          property :p => [String, Range] do |a,b| a == b end
        end

        it_should_behave_like 'PropertyWithoutCases'
      end


      describe ExhaustiveStrategy, 'with a property that has many cases, arity=1' do
        def define_prop
          property :p => [String] do |a| a.length == 0 end
        end

        it_should_behave_like 'PropertyWithCases'

        it 'should generate correctly all strings of increasing sizes' do
          @strategy.generate.should == ['']
          @strategy.exhausted?.should be_false
          @strategy.progress.should == 0.5
          s1 = []
          128.times { s1 << @strategy.generate.first }
          s1.should == (0..127).map { |c| c.chr }
          @strategy.exhausted?.should be_false
          @strategy.progress.should == 1
          @strategy.generate.should == ["\0\0"]
          @strategy.generate.should == ["\0\1"]
          @strategy.exhausted?.should be_false
          @strategy.progress.should == 1
        end
      end


      describe ExhaustiveStrategy, 'with a property that has many cases, arity =2' do
        def define_prop
          property :p => [String, String] do |a,b| a == b end
        end

        it_should_behave_like 'PropertyWithCases'

        it 'should generate correctly all strings of increasing sizes' do
          @strategy.generate.should == ['', '']
          @strategy.exhausted?.should be_false
          @strategy.progress.should == 0.5
          @strategy.generate.should == ["\0", "\0"]
          127.times do
            s = @strategy.generate
            s.first.length.should == 1
            s.last.length.should == 1
          end
          @strategy.generate.should == ["\1", "\0"]
          @strategy.exhausted?.should be_false
          @strategy.progress.should == 0.5
        end
      end
    end
  end
end
