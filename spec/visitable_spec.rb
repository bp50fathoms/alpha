require 'visitable'


class Foo; include Visitable end


module VisitableSpec
  class Foo; include Visitable end


  module Bar
    class Foo; include Visitable end
  end


  shared_examples_for Visitable do
    before(:each) do
      @foo = build
      @visitor = mock('visitor')
    end

    after(:each) do
      @visitor = @foo = nil
    end

    def accept_and_check(*args)
      @visitor.should_receive(:visit_foo).once.with(*([@foo] + args))
      @foo.accept(@visitor, *args)
    end

    it 'should accept a visitor and 0 arguments' do
      accept_and_check()
    end

    it 'should accept a visitor and 1 argument' do
      accept_and_check(1)
    end

    it 'should accept a visitor and 2 arguments' do
      accept_and_check(1, :a)
    end

    it 'should accept a visitor and n arguments (n = 5)' do
      accept_and_check(1, :a, true, 1.0, 'bc')
    end
  end


  describe ::Foo, 'include Visitable' do
    def build
      ::Foo.new
    end

    it_should_behave_like 'Visitable'
  end


  describe VisitableSpec::Foo, 'include Visitable' do
    def build
      VisitableSpec::Foo.new
    end

    it_should_behave_like 'Visitable'
  end


  describe VisitableSpec::Bar::Foo, 'include Visitable' do
    def build
      VisitableSpec::Bar::Foo.new
    end

    it_should_behave_like 'Visitable'
  end
end
