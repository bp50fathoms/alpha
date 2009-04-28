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

      property :e => [Fixnum, Fixnum] do |a,b|
        (a > b) | (a <= b)
      end
    end

    it 'should run all unary properties and those with greater arity correctly' do
      define_prop
      runner(PList.all, s = StringIO.new)
      s.string.should ==
        "Checking 5 properties\n" +
        "a\n" +
        "Success\n" +
        "b\n" +
        "Failure\n" +
        "c\n" +
        "Failure\n" +
        "Unhandled exception object expected\n" +
        "d\n" +
        "Failure\n" +
        "No test cases could be generated\n" +
        "e\n" +
        "....Success\n"
    end

    it 'should falsify a very simple unsound property' do
      property :p => [Fixnum] do |a|
        a >= 100
      end
      falsify
    end

    it 'should falsify another very simple unsound property' do
      property :p => [Fixnum] do |a|
        a <= 388
      end
      falsify
    end

    it 'should cover a simple sound property' do
      property :p => [Fixnum, Fixnum] do |a,b|
        (a >= b) | (a < b)
      end
      not_falsify_and_cover
    end

    it 'should falsify a simple unsound property' do
      property :p => [Fixnum, Fixnum] do |a,b|
        (a > b) | (a < b)
      end
      o = falsify
      c = o.falsifying_case
      c.first.should == c.last
    end

    it 'should falsify a simple lazy unsound property' do
      property :p => [Fixnum, Fixnum] do |a,b|
        a > b or a < b
      end
      o = falsify
      c = o.falsifying_case
      c.first.should == c.last
    end

    it 'should falsify a compound unsound property' do
      property :p => [Fixnum, Fixnum, Fixnum, Fixnum] do |a,b,c,d|
        (a >= b) & (a < b) & (c != d)
      end
      falsify
    end

    def bar(a, b)
      if a == 87 and b == 88
        raise 'e'
      else
        true
      end
    end

    it 'should falsify complex preconditions' do
      property :p => [Fixnum, Fixnum] do |a,b|
        ((a > 86) & (a <= 88) & (b > 86) & (b <= 88)) ? bar(a,b) : true
      end
      o = falsify
      o.falsifying_case.should == [87, 88]
    end

    it 'should deal gracefully with properties that throw exceptions' do
      property :p => [Fixnum, Fixnum, Fixnum] do |a,b,c|
        raise ''
      end
      falsify
    end

    def runner(list, string)
      r = GeneticRunner.new
      r.add_observer(UI.new(string))
      (list | r).output
    end

    def falsify
      o = runner(PList.all, StringIO.new)[0]
      o.falsified?.should be_true
      o
    end

    def not_falsify_and_cover
      o = runner(PList.all, StringIO.new)[0]
      o.falsified?.should be_false
      o.cover_table.covered?.should be_true
      o
    end
  end
end
