require 'property_helpers'


module PropertyCasesSpec
  describe Property do
    include PropertyHelpers

    it_should_behave_like 'Property'

    it 'should accept a simple sequence of cases to be checked' do
      p = property :p => String do
        predicate { |s| s.size == s.length }

        always_check [''], ["\\\?"]
      end
      p.cases.should == [[''], ["\\\?"]]
    end

    it 'should accept one case to be checked' do
      p = property :p => String do
        predicate { |s| s.size == s.length }

        always_check ['']
      end
      p.cases.should == [['']]
    end

    it 'should accept a simple sequence in a property with arity > 1' do
      p = property :p => [String, String] do
        predicate { |a, b| a == b }

        always_check ['', ''], ['a', 'a']
      end
      p.cases.should == [['', ''], ['a', 'a']]
    end

    it 'should accept one case in a property with arity > 1' do
      p = property :p => [String, String] do
        predicate { |a, b| a == b }

        always_check ['', '']
      end
      p.cases.should == [['', '']]
    end

    it 'should reject a number of cases with wrong arity' do
      lambda do
        p = property :p => String do
          predicate { |s| s.size == s.length }

          always_check ['', '']
        end
      end.should raise_error(ArgumentError)
    end
  end
end
