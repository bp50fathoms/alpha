require 'pipeline'


module PipesSpec
  class Initial
    include PipelineElement

    def output
      [0, 1, 2, 3]
    end
  end


  class Even
    include Filter

    def process(input)
      input.select { |e| e % 2 == 0 }
    end
  end


  class NonZero
    include Filter

    def process(input)
      input.select { |e| e > 0 }
    end
  end


  class Null
    include Filter

    def output
      input unless @pipe.nil?
      nil
    end
  end


  describe 'Pipeline initial | even' do
    it 'should output only the evens' do
      (Initial.new | Even.new).output.should == [0, 2]
    end
  end


  describe 'Pipeline initial | nonZero' do
    it 'should output all except 0' do
      (Initial.new | NonZero.new).output.should == [1, 2, 3]
    end
  end


  shared_examples_for 'even_nonZero' do
    it 'should output only the non-zero evens' do
      @pipeline.output.should == [2]
    end
  end


  describe 'Pipeline initial | nonZero | even' do
    before(:each) do
      @pipeline = Initial.new | NonZero.new | Even.new
    end

    it_should_behave_like 'even_nonZero'
  end


  describe 'Pipeline initial | even | nonZero' do
    before(:each) do
      @pipeline = Initial.new | Even.new | NonZero.new
    end

    it_should_behave_like 'even_nonZero'
  end


  shared_examples_for 'nil_in_the_middle' do
    it 'should not crash and output nil' do
      @pipeline.output.should == nil
    end
  end


  describe 'Pipeline null | even | nonZero' do
    before(:each) do
      @pipeline = Null.new | Even.new | NonZero.new
    end

    it_should_behave_like 'nil_in_the_middle'
  end


  describe 'Pipeline initial | null | even' do
    before(:each) do
      @pipeline = Initial.new | Null.new | Even.new
    end

    it_should_behave_like 'nil_in_the_middle'
  end


  describe 'Pipeline initial | even | null' do
    before(:each) do
      @pipeline = Initial.new | Even.new | Null.new
    end

    it_should_behave_like 'nil_in_the_middle'
  end
end
