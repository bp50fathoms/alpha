require 'property'
require 'strategy'


class CasesStrategy < Strategy
  private

  def gen
    @property.cases[@count]
  end

  def can
    !@property.cases.nil?
  end

  def exh
    @property.cases.size == @count
  end

  def pro
    @count.to_f / @property.cases.size
  end
end
