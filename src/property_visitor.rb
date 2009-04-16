require 'property'
require 'rubygems'
require 'ruby2ruby'
require 'parse_tree'
require 'parse_tree_extensions'


class PropertyVisitor < SexpProcessor
  def initialize(property)
    super()
    proc_body(property.predicate.to_sexp)
  end

  def proc_body(exp)
    # p exp
    3.times { exp.shift }
    raise 'Empty property body' if exp.empty?
    process(exp.shift)
  end

  def process_lvar(exp)
    exp.shift
    exp.shift
    s()
  end

  def process_call(exp)
    while !exp.empty?
      exp.shift
    end
    s()
  end
end
