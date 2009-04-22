require 'decorator'
require 'dotvisitor'
require 'initializer'
require 'property'


module DOTVisitorSpec
  describe DOTVisitor do
    class P
      include Decorator
      attrs(:decorated, :cover_table)
    end

    before(:all) do
      $n = 0
    end

    before(:each) do
      @r = ResultCollector.new
    end

    after(:each) do
      g = GraphViz.new('g', :output => 'pdf', :file => "out/#{$n}.pdf")
      $n += 1
      c = CoverTable.new(@p.cover_goal)
      c.add_result(@r)
      dp = P.new(@p, c)
      DOTVisitor.new(g, dp)
      g.output
      @r = @p = nil
    end

    it 'should plot correctly a green success tree when coverage is achieved' do
      @p = property :p => [String] do |a|
        not a.length < 0
      end
      @p.call('', @r)
    end

    it 'should plot correctly red errors when coverage is not achieved' do
      @p = property :p => [String] do |a|
        (a.length > 1) | (a.length <= 1)
      end
      @p.call('', @r)
    end

    it 'should plot correctly orange warnings when case distribution is uneven' do
      @p = property :p => [Array] do |a|
        a.any? { |e| e > 0 }
      end
      @p.call([-1] * 1000 + [1], @r)
    end

    it 'should deal correctly with Boolean constants' do
      @p = property :p => [String] do |a|
        true
      end
    end

    it 'should deal correctly with conditionals' do
      @p = property :p => [String] do |a|
        if a.length > 0
          a.length > 0
        else
          a.length == 0
        end
      end
      @p.call('a', @r)
      @p.call('', @r)
    end

    it 'should deal correctly with property composition' do
      property :r => [Fixnum] do |a|
        a >= 0
      end

      property :q => [Array] do |a|
        a.any? { |e| Property.r(e) }
      end

      @p = property :p => [Array] do |a|
        not Property.q(a)
      end

      @p.call([-1, -2, -3] * 20, @r)
    end

    it 'should deal correctly with contracts' do
      class Foo
        def bar(baz)
          Math.sqrt(baz)
        end

        contract :bar => [Fixnum] do
          requires { |n| n >= 0 }
          ensures { |n,r| (r ** 2 - n).abs < 1e-5 }
        end
      end
      @p = Property[:'DOTVisitorSpec::Foo.bar']
      @p.call(Foo.new, -88, @r)
      @p.call(Foo.new, 4, @r)
    end
  end
end
