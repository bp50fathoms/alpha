require 'dotvisitor'
require 'property'
require 'decorator'


module DOTVisitorSpec
  describe DOTVisitor do
    class P
      include Decorator

      attr_reader :decorated, :cover_table

      def initialize(p, ct)
        @decorated = p
        @cover_table = ct
      end
    end

    before(:all) do
      @n = 0
    end

    def graphviz
      g = GraphViz.new('g', :output => 'pdf', :file => "#{@n}.pdf")
      @n += 1
      g
    end

    it 'should plot correctly composed properties' do
      # composicion brutal

      # g = graphviz
      # property :q => [String] do |s|
      #   (s == 'a') | (s == 'b')
      # end
      # p = property :p => [String, Array] do |a,b|
      #   (b.all? { |e| e > 0 }) | (Property.q(a))
      # end
      # r = ResultCollector.new
      # c = CoverTable.new(p.cover_goal)
      # p.call('a', [1,2,3,0], r)
      # p.call('b', [-1], r)
      # p.call('c', [1,2], r)
      # c.add_result(r)
      # dp = P.new(p, c)
      # DOTVisitor.new(g, dp)
      # g.output
    end

    it 'should plot correctly warnings when case distribution is uneven' do
      # uneven brutal
      g = graphviz
      p = property :p => [Array] do |a|
        a.any? { |e| e > 0 }
      end
      r = ResultCollector.new
      c = CoverTable.new(p.cover_goal)
      p.call([-1] * 1000 + [1], r)
      c.add_result(r)
      dp = P.new(p, c)
      DOTVisitor.new(g, dp)
      g.output
    end
  end
end
