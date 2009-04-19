class ResultCollector
  attr_reader :result

  def initialize
    @result = {}
  end

  def store(expr, obj)
    r = @result[expr]
    if r
      @result[expr] = r + [obj]
    else
      @result[expr] = [obj]
    end
    obj
  end
end
