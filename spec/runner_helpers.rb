require 'batchui'
require 'property_helpers'


module RunnerHelpers
  shared_examples_for 'Runner' do
    include PropertyHelpers

    it_should_behave_like 'Property'

    class Foo
      def bar(baz)
        Math.sqrt(baz)
      end
    end

    def define_prop
      property :a do true end

      property(:b) { false }

      property :c => [String, String] do
        predicate { |a, b| a.length > b.length }

        always_check ["aa", "a"], ["abc", "cde"]
      end

      property :d => [Object, Object] do
        predicate { |x, y| x != y }
      end

      property(:e) { raise nil }

      property :f => String do
        predicate { |s| s.length >= 0 }

        always_check [''], [nil], ['a']
      end

      property :g => [String, String] do
        predicate { |s,t| s.length == t.length }

        always_check ['', ''], ['a', 'a'], ['ab', 'ab']
      end

      c = Contract.new(Foo.instance_method(:bar), [Fixnum]) do
        requires { |n| n >= 0 }
        ensures { |n,r| (r ** 2 - n).abs < 1e-5 }

        always_check [Foo.new, 2], [Foo.new, -2]
      end

      [Property[:a], Property[:b], Property[:c], Property[:d], Property[:e],
       Property[:f], Property[:g], Property[:'RunnerHelpers::Foo.bar']]
    end

    it 'should run all properties with cases correctly' do
      r = runner
      s = StringIO.new
      r.add_observer(UI.new(s))
      (PList[*define_prop] | r).output
      s.string.should ==
        "Checking 8 properties\n" +
        "a\n" +
        "Success\n" +
        "b\n" +
        "Failure\n" +
        "c\n" +
        "..Failure\n" +
        "Input [\"abc\", \"cde\"]\n" +
        "d\n" +
        "Failure\n" +
        "No test cases could be generated\n" +
        "e\n" +
        "Failure\n" +
        "Unhandled exception object expected\n" +
        "f\n" +
        "..Failure\n" +
        "Input [nil]\n" +
        "Unhandled undefined method `length' for nil:NilClass\n" +
        "g\n" +
        "...Success\n" +
        "RunnerHelpers::Foo.bar\n" +
        "..Success\n"
    end
  end
end
