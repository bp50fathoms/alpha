require 'cases'
require 'complexrunner'
require 'runner_helpers'


module ComplexRunnerSpec
  describe ComplexRunner do
    include RunnerHelpers

    it_should_behave_like 'Runner'

    DB = File.expand_path(File.dirname(__FILE__) + '/errors.db')

    before(:each) do
      begin
        File.delete(DB)
      rescue
      end
    end

    after(:each) do
      File.delete(DB)
    end

    def runner
      ComplexRunner.new(DB, CasesStrategy.new)
    end
  end
end
