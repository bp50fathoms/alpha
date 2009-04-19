class CoverTable
  attr_reader :table

  def initialize(coverage_goal)
    @table = {}
    coverage_goal.each_pair { |k,v| @table[k] = Hash[*v.map { |e| [e,0] }.flatten] }
  end

  def add_result(rc)
    # solo actualizar valores contenidos en la tabla
    rc.result.each_pair do |k,v|

    end
  end

  def covered?
    cover_factor == 1.0
  end

  def cover_factor
    # numero de entradas con todas las subentradas > 0
  end
end
