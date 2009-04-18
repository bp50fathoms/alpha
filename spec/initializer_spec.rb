require 'initializer'


module InitializerSpec
  class Bar
    attr_reader *initialize_with(:a, :b)
  end


  class FooBar < Bar
    attr_reader *initsuper_with([:c, :d], [:a, :b]) { @e = 8 }

    attr_reader :e
  end


  class FogBugz < Bar
    attr_reader *initsuper_with([:c, Default[:d, 80]],
                                [Default[:a, 81], Default[:b, 82]])
  end


  describe Class do
    it 'should have public initialize_with defined' do
      Class.public_method_defined?(:initialize_with).should == true
    end
  end


  shared_examples_for 'initialization' do
    before(:all) do
      @klass = klass
    end

    after(:all) do
      @klass = nil
    end

    def max; min end

    it 'should reject less than min arguments' do
      lambda { @klass.new(*Array.new(min - 1 > 0 ? min - 1 : 0, 0)) }.should
      raise_error(ArgumentError)
      lambda { @klass.new(*Array.new(min - 2 > 0 ? min - 2 : 0, 0)) }.should
      raise_error(ArgumentError)
    end

    it 'should reject more than max arguments' do
      lambda { @klass.new(*Array.new(max + 1 > 0 ? min - 1 : 0, 0)) }.should
      raise_error(ArgumentError)
      lambda { @klass.new(*Array.new(max + 2 > 0 ? min - 2 : 0, 0)) }.should
      raise_error(ArgumentError)
    end
  end


  describe Bar, 'initialize_with(:a, :b)' do
    it_should_behave_like 'initialization'

    def klass; Bar end

    def min; 2 end

    it 'should have initialize(a, b) defined' do
      object = @klass.new(1, 2)
      object.a.should == 1
      object.b.should == 2
    end
  end


  describe FooBar, '< Foo initsuper_with([:c, :d], [:a, :b])' do
    it_should_behave_like 'initialization'

    def klass; FooBar end

    def min; 4 end

    it 'should call super with the provided arguments' do
      object = @klass.new(1, 2, 3, 4)
      object.c.should == 1
      object.d.should == 2
      object.a.should == 3
      object.b.should == 4
    end

    it 'should call initialize_rest with no arguments' do
      @klass.new(1, 2, 3, 4).e.should == 8
    end
  end


  describe FogBugz, '< Bar attr_reader *initsuper_with([:c, Default[:d, 80]],
  [Default[:a, 81], Default[:b, 82]])' do
    it_should_behave_like 'initialization'

    def klass; FogBugz end

    def min; 1 end

    def max; 4 end

    it 'should call super with the provided arguments (no defaults)' do
      object = @klass.new(1, 2, 3, 4)
      object.c.should == 1
      object.d.should == 2
      object.a.should == 3
      object.b.should == 4
    end

    it 'should call super with the provided arguments (1 default)' do
      object = @klass.new(1, 2, 3)
      object.c.should == 1
      object.d.should == 2
      object.a.should == 3
      object.b.should == 82
    end

    it 'should call super with the provided arguments (2 defaults)' do
      object = @klass.new(1, 2)
      object.c.should == 1
      object.d.should == 2
      object.a.should == 81
      object.b.should == 82
    end

    it 'should call super with the provided arguments (3 defaults)' do
      object = @klass.new(1)
      object.c.should == 1
      object.d.should == 80
      object.a.should == 81
      object.b.should == 82
    end
  end
end
