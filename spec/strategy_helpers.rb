require 'strategy'


module StrategyHelpers
  shared_examples_for 'NewStrategy' do
    before(:each) do
      @strategy = strategy.new
    end

    after(:each) do
      @strategy = nil
    end

    it 'should refuse to generate when just built' do
      lambda { @strategy.generate }.should raise_error
    end

    it 'should refuse to report if it is exhausted when just built' do
      lambda { @strategy.exhausted? }.should raise_error
    end

    it 'should refuse to report progress when just built' do
      lambda { @strategy.progress }.should raise_error
    end
  end


  shared_examples_for 'Strategy' do
    before(:each) do
      Property.clear
      @strategy = strategy.new
      set_up
      @strategy.set_property(define_prop)
    end

    after(:each) do
      Property.clear
      tear_down
      @strategy = nil
    end

    def set_up; end

    def tear_down; end
  end


  shared_examples_for 'PropertyWithoutCases' do
    it 'should refuse to generate' do
      lambda { @strategy.generate }.should raise_error
    end

    it 'should be exhausted' do
      @strategy.exhausted?.should be_true
    end

    it 'should have 0 progress' do
      @strategy.progress.should == 0
    end
  end


  shared_examples_for 'PropertyWithCases' do
    it 'should not be exhausted when just initialized' do
      @strategy.exhausted?.should be_false
    end

    it 'should have not progressed when just initialized' do
      @strategy.progress.should == 0
    end
  end
end
