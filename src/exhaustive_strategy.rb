require 'generator'
require 'strategy'


class ExhaustiveStrategy < Strategy
  include Exhaustive

  def initialize(goal = 2)
    @goal = goal
  end

  private

  def set(property)
    if can
      @tuple = product(*@property.types)
      @next_depth = 0
      @levels = 0
      set_gen
    end
  end

  def set_gen
    @generator = Generator.new(@tuple.exhaustive(@next_depth))
    @next_depth += 1
  end

  def gen
    if @generator.next?
      r = @generator.next
    else
      set_gen
      r = gen
    end
    @levels += 1 unless @generator.next?
    r
  end

  def can
    @property.types.all? { |t| t.respond_to?(:exhaustive) }
  end

  def exh
    false
  end

  def pro
    @levels.to_f / @goal
  end
end
