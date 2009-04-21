require 'rubygems'
require 'graphviz'


class DOTVisitor
  attr_reader :graph, :property

  def initialize(graph, property)
    @graph = graph
    @property = property
    @nodes = {}
    property.tree.accept(self)
  end

  def visit_unaryexpr(e)
    add_node(e, e.operator.to_s)
    visit_and_link(e, e.expr)
  end

  def visit_binaryexpr(e)
    add_node(e, e.operator.to_s)
    visit_and_link(e, e.left_expr)
    visit_and_link(e, e.right_expr)
  end

  def visit_quantexpr(e)
    add_node(e, e.type.to_s)
    visit_and_link(e, e.expr)
  end

  def visit_conditional(e)
    add_node(e, 'if')
    visit_and_link(e, e.condition)
    visit_and_link(e, e.then_branch)
    visit_and_link(e, e.else_branch)
  end

  def visit_composition(e)
    visit(Property[e.property].tree)
  end

  def visit_boolconst(e)
    addcnode(e, 'green', e.value.to_s)
  end

  def visit_boolatom(e)
    add_node(e, 'atom')
  end

  private

  def key(object)
    object.object_id.to_s
  end

  def visit_and_link(parent, child)
    add_edge(parent, visit(child))
    parent
  end

  def add_node(node, label)
    info = property.cover_table.table[node]
    v = info.values
    if v.include?(0)
      color = 'red'
    else
      mrate = v.inject(:+) * 0.1
      color = (!v.select { |e| e < mrate }.empty? ? 'orange' : 'green')
    end
    addcnode(node, color, label)
  end

  def addcnode(node, color, label)
    @nodes[node.object_id] = @graph.add_node(key(node), { :label => label,
                                               :color => color,
                                               :style => 'filled' })
    node
  end

  def add_edge(parent, child)
    @graph.add_edge(key(parent), key(child))
  end

  def visit(object, *args)
    object.accept(self, *args)
  end
end
