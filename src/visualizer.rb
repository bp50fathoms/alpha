require 'dotvisitor'
require 'graphviz'
require 'initializer'
require 'pipeline'


class Visualizer
  include Filter

  initialize_with :path, Default[:open, false]

  def process(i)
    i.select { |p| !p.falsified? and p.arity > 0 }.each do |p|
      file = "#{@path}/#{p.key}.pdf"
      g = GraphViz.new('g', :output => 'pdf', :file => file)
      DOTVisitor.new(g, p)
      g.output
      `open #{file}` if @open
    end
  end
end
