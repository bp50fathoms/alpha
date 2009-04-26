require 'genetic_fitness'
require 'genetic_tleafs'
require 'initializer'
require 'property'


class ChromosomeFactory
  include GeneticTreeLeafs

  attr_reader :property, :goal

  def initialize(property, permutation)
    @property = property
    h = []
    leafs(property.tree).each_with_index { |e,i| h << e; h << permutation[i] }
    @goal = Hash[*h]
  end

  def mutate(chromosome)
    # quizas cambiar mas elementos
    i = rand(property.arity)
    s = rand(2) == 1 ? -1 : 1
    chromosome.data[i] += s * rand(10)
    chromosome
  end

  def reproduce(a, b)
    crossover = rand(property.arity + 1)
    sa = crossover == 0 ? [] : a.data[0..crossover-1]
    sb = b.data[crossover..-1]
    Chromosome.new(self, sa + sb)
  end

  def seed
    Chromosome.new(self, Array.new(property.arity) { |e| rand(100) })
  end
end


class Chromosome

  attr_accessor :data, :normalized_fitness

  def initialize(factory, data)
    @factory = factory
    @data = data
  end

  def fitness
    res = eval_property.result
    goal = @factory.goal
    goal.map do |e|
      if !res.has_key?(e.first)
        GeneticFitness::MAXFIT
      elsif e.first.is_a?(BoolAtom) and e.first.comp
        op = e.first.comp.operator
        gl = e.last
        args = [res[e.first.comp.left_expr], res[e.first.comp.right_expr]].flatten
        GeneticFitness.fitness(op, gl, *args)
      else
        GeneticFitness.fitness(:atom, e.last, res[e.first])
      end
    end.inject(:+) * -1
  end

  private

  def eval_property
    rc = ResultCollector.new
    r = @factory.property.call(*(data + [rc]))
    if r
      @factory.property.cover_table.add_result(rc)
      rc
    else
      raise FalsifiedProperty.new(data)
    end
  end
end


class FalsifiedProperty < Exception
  attr_reader *(initialize_with(:case))
end
