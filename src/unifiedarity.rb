module UnifiedArity
  def ar(block)
    arity = block.arity
    arity == -1 ? 0 : arity
  end

  module_function :ar
end
