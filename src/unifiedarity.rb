require 'rubygems'
require 'parse_tree'
require 'parse_tree_extensions'
require 'ruby2ruby'


module UnifiedArity
  def ar(block)
    arity = block.arity
    if arity != -1
      arity
    else
      if block.to_ruby =~ /\|\*\w+\|/
        -1
      else
        0
      end
    end
  end

  module_function :ar
end
