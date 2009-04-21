module Enumerable
  class LazyGenerator
    include Enumerable

    def initialize(&body)
      @body = body
    end

    def each(&block)
      @body.call(block)
    end
  end


  def lazy_apply(&block)
    LazyGenerator.new do |y|
      each do |*input|
        block.call(y, *input)
      end
    end
  end
end
