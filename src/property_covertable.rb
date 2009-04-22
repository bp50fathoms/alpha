class CoverTable
  attr_reader :table

  def initialize(property)
    @table = {}
    property.cover_goal.each_pair do |k,v|
      @table[k] = Hash[*v.map { |e| [e,0] }.flatten]
    end
  end

  def add_result(rc)
    rc.result.each_pair do |k,v|
      if table.has_key?(k)
        v.each { |e| table[k][e] += 1 if table[k][e] }
      end
    end
  end

  def covered?
    cover_factor == 1.0
  end

  def cover_factor
    if table.empty?
      1.0
    else
      covered = table.values.select { |t| t.values.all? { |e| e > 0 } }.length
      covered / table.length.to_f
    end
  end
end
