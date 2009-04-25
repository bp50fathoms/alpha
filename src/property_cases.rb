class Property
  attr_reader :cases

  def always_check(*cases)
    unless cases.map { |e| e.size == arity }.inject(:&)
      raise ArgumentError, "wrong number of cases for arity #{arity}"
    end
    @cases = cases
  end
end
