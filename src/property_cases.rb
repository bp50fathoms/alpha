class Property
  attr_reader :cases

  def always_check(*cases)
    c = cases.map { |e| e.is_a?(Array) ? e : [e] }
    unless c.map { |e| e.size == arity }.inject(:&)
      raise ArgumentError, "wrong number of cases for arity #{arity}"
    end
    @cases = c
  end
end
