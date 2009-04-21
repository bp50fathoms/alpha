require 'strategy'


class RandomStrategy < Strategy
  def initialize(goal = 100)
    @goal = goal
  end

  private

  def gen
    @property.types.map { |t| t.arbitrary }
  end

  def can
    @property.types.all? { |t| t.respond_to?(:arbitrary) }
  end

  def exh
    false
  end

  def pro
    @count.to_f / @goal
  end
end
