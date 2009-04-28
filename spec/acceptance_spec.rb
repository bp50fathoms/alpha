require 'facade'
require 'property_helpers'


module AcceptanceSpec
  describe 'Acceptance specs' do
    it_should_behave_like 'Property'

    def define_properties
      desc 'Sound property of arity 0'
      property(:a) { [].length == [].size }

      desc 'Unsound property of arity 0'
      property :b do
        [].length > 0
      end

      desc 'Property of arity 0 that raises exception'
      property :c do
        raise 'One exception'
      end

      desc 'Sound property of arity > 0'
      property :d => String do |s|
        s.length >= 0
      end

      desc 'Unsound property of arity > 0'
      property(:e => [String]) do
        predicate { |s| s.length >= 2 }
        always_check 'a', 'b', 'abc'
      end

      desc 'Property of arity > 0 that raises exception'
      property :f => [String, String] do |s1,s2|
        s1.abc == s2.abc
      end

      desc 'Property without cases'
      property :g => [Range, Range, Range] do |a,b,c|
        true
      end
    end
  end
end
