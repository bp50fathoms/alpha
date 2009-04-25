class ChromosomeFactory
  attr_reader :property, :goal

  def initialize(property, leafs, permutation)
    @property = property
    h = []
    leafs.each_with_index { |e,i| h << e; h << permutation[i] }
    @goal = Hash[*h]
  end

  def mutate(chromosome)
    # cambiar aleatoriamente elementos del cromosoma
    # cambiar signo tambien
  end

  def reproduce(a, b)
    crossover = rand(goal.length + 1)
    sa = crossover == 0 ? [] : a[0..crossover-1]
    sb = b[crossover..-1]
    Chromosome.new(self, sa + sb)
  end

  def seed
    Chromosome.new(self, Array.new(goal.length) { |e| rand(100) })
  end
end


class Chromosome
  attr_accessor :data, :normalized_fitness

  def initialize(factory, data)
    @factory = factory
    @data = data
  end

  def fitness
    # calcular usando modulo y evaluando propiedad
    # lanzar excepcion si evalua a false
    # acordarse de actualizar covertable
  end
end
