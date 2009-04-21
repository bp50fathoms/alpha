require 'errordatabase'
require 'strategy'


class HistoricStrategy < Strategy
  def initialize(factor = 1.0)
    @factor = factor
  end

  private

  def set(property)
    @data = @runner.db.get_cases(property)
  end

  def gen
    @data[@count]
  end

  def can
    true
  end

  def exh
    @count == @data.length
  end

  def pro
    @count / @factor * @data.length
  end
end
