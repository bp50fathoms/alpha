require 'batchui'
require 'genetic_runner'


module GeneticRunnerSpec
  describe GeneticRunner do
    it_should_behave_like 'Property'

    def define_prop
      property :a do true end

      property(:b) { false }

      property(:c) { raise nil }

      property :d => String do |a|
        a == 'a'
      end

      property :e => Fixnum do |a|
        a >= 0
      end
    end

    it 'should run all unary properties and those with greater arity correctly' do
      define_prop
      r = GeneticRunner.new
      s = StringIO.new
      r.add_observer(UI.new(s))
      (PList.all | r).output
      p s.string
      s.string.should ==
        "Checking 4 properties\n" +
        "a\n" +
        "Success\n" +
        "b\n" +
        "Failure\n" +
        "c\n" +
        "Failure\n" +
        "Unhandled exception object expected\n" +
        "d\n" +
        "Failure\n" +
        "No test cases could be generated\n"
    end
  end
end
