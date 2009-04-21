require 'contract'
require 'property_helpers'


module ContractLanguageSpec
  describe Class do
    it_should_behave_like 'Property'

    class Foo
      def bar(baz); end
      def foobar; end
    end


    it 'should build a contract with => notation' do
      class Foo
        contract :bar => [Float] do
          requires { |e| }
          ensures { |e,r| }
        end
      end
      c = Property[:'ContractLanguageSpec::Foo.bar']
      c.types.should == [ContractLanguageSpec::Foo, Float]
    end

    it 'should build a contract for a method of arity 0' do
      class Foo
        contract :foobar do
          requires {}
          ensures { |r| }
        end
      end
      c = Property[:'ContractLanguageSpec::Foo.foobar']
      c.types.should == [ContractLanguageSpec::Foo]
    end

    it 'should build a contract with => notation and without Array' do
      class Foo
        contract :bar => Float do
          requires { |e| }
          ensures { |e,r| }
        end
      end
      c = Property[:'ContractLanguageSpec::Foo.bar']
      c.types.should == [ContractLanguageSpec::Foo, Float]
    end

    it 'should reject unknown instance methods' do
      lambda do
        class Foo
          contract :foo do
            requires { |e| }
            ensures { |e,r| }
          end
        end
      end.should raise_error(Exception)
    end

    it 'should reject a contract with a long hash in its signature' do
      lambda do
        class Foo
          contract :bar => Float, :baz => [Float] do
            requires { |e| }
            ensures { |e,r| }
          end
        end
      end.should raise_error(ArgumentError)
    end
  end
end
