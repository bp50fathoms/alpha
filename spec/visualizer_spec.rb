require 'facade'
require 'property_helpers'


module VisualizerSpec
  describe Visualizer do
    it_should_behave_like 'Property'

    def define_prop
      property :p => [String] do
        predicate { |a| a != 'a' }
        always_check 'a'
      end

      property :q => [String] do |a|
        if a.length > 0
          a.length > 0
        else
          a.length == 0
        end
      end
    end

    it 'should work correctly in the pipeline' do
      define_prop
      sr = SimpleRunner.new
      sr.add_observer(BatchUI.new(StringIO.new))
      (PList.all | sr | do!{|i| i.select{|p| !p.falsified?}} |
       Visualizer.new('out')).output
    end
  end
end
