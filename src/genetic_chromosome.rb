require 'genetic_fitness'
require 'initializer'
require 'property'


class ChromosomeFactory
  attr_reader :property, :goal

  def initialize(property, leafs, permutation)
    @property = property
    h = []
    leafs.each_with_index { |e,i| h << e; h << permutation[i] }
    @goal = Hash[*h]
  end

  def mutate(chromosome)
    # quizas cambiar mas elementos
    i = rand(property.arity)
    s = rand(2) == 1 ? -1 : 1
    chromosome.data[i] += s * rand(2)
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
    r, rc = eval_property
    raise FalsifiedProperty.new(data) unless r
    g = @factory.goal
    g.map do |e|
      if e.first.is_a?(BoolAtom) and e.first.comp
        p e.first
        p op = e.first.comp.operator
        p gl = e.last
        p args = [rc.result[e.first.comp.left_expr],
                  rc.result[e.first.comp.right_expr]].flatten
        GeneticFitness.fitness(op, gl, *args)
      else
        GeneticFitness.fitness(:atom, e.last, rc.result[e.first])
      end
    end.inject(:+) * -1
    # cuidado con caso de que no evaluen algunas hojas
  end

  private

  def eval_property
    rc = ResultCollector.new
    r = @factory.property.call(*(data + [rc]))
    @factory.property.cover_table.add_result(rc) if r
    [r, rc]
  end
end


class FalsifiedProperty
  attr_reader *(initialize_with(:case))
end
