require 'decorator'


class ResultCollector
  attr_reader :result

  def initialize
    @result = {}
  end

  def store_obj(expr, obj)
    store(expr, nil, obj)
  end

  def store(expr, method, obj, *args)
    if method
      result[expr] = obj.send(method, *args)
    else
      result[expr] = obj
    end
  end
end
