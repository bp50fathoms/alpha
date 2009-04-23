module Random
  def frequency(hash)
    FrequencyCombinator.new(hash)
  end


  class FrequencyCombinator
    def initialize(hash)
      @values = []
      hash.each_pair { |k,v| v.times { @values << k } }
    end

    def arbitrary
      e = @values[rand(@values.size)]
      e.respond_to?(:arbitrary) ? e.arbitrary : e
    end
  end


  def one_of(*ary)
    expanded = []
    ary.each { |e| e.is_a?(Enumerable) ? expanded += e.to_a : expanded << e }
    hash = {}
    expanded.each { |e| hash[e] = 1 }
    frequency(hash)
  end

  module_function :frequency, :one_of
end
