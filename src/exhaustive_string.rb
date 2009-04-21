require 'permutations'


class String
  def self.exhaustive(n)
    StringIterator.new(n)
  end

  class StringIterator
    include Enumerable, Permutations

    def initialize(n)
      @n = n
    end

    def each(&block)
      r = (0..127).to_a.map { |e| e.chr }
      unless @n == 0
        head = lambda { |v,i| "for #{v} in r" }
        yld = lambda { |y| "yield(#{y})" }
        eval(genc(@n, head, '+', yld), binding)
      else
        yield('')
      end
    end
  end
end
