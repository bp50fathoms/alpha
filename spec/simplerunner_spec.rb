require 'runner_helpers'
require 'simplerunner'


module SimpleRunnerSpec
  describe SimpleRunner do
    include RunnerHelpers

    it_should_behave_like 'Runner'

    def runner
      SimpleRunner.new
    end
  end
end
