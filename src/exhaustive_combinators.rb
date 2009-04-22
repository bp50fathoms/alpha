require 'initializer'
require 'permutations'


module Exhaustive
  def product(*ary)
    ProductCombinator.new(ary)
  end

  def union(*ary)
    UnionCombinator.new(ary)
  end


  class Combinator
    initialize_with :ary, :finalc

    def exhaustive(n)
      @finalc.new(n, @ary)
    end
  end


  class ProductCombinator < Combinator
    def initialize(ary)
      super(ary, Product)
    end
  end


  class UnionCombinator < Combinator
    def initialize(ary)
      super(ary, Union)
    end
  end


  class Product
    include Enumerable

    initialize_with :n, :ary

    def each(&block)
      head = lambda { |v,i| "@ary[#{i}].exhaustive(@n).each do |#{v}|" }
      yld = lambda { |y| "yield([#{y}])" }
      eval(Permutations.genc(@ary.size, head, ',', yld), binding)
    end
  end


  class Union
    include Enumerable

    initialize_with :n, :ary

    def each(&block)
      @ary.each do |e|
        e.exhaustive(@n).each { |e| yield(e) }
      end
    end
  end
end
