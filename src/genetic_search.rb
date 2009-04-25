# Some code adapted from gga4r gem (library), fixing existing bugs
class GeneticSearch
  attr_accessor :population

  def initialize(chromosome, initial_population_size, generations)
    @chromosome = chromosome
    @population_size = initial_population_size
    @max_generation = generations
    @generation = 0
  end

  def run
    generate_initial_population
    @max_generation.times do
      selected_to_breed = selection
      offsprings = reproduction selected_to_breed
      replace_worst_ranked offsprings
    end
    return best_chromosome
  end

  def generate_initial_population
    @population = []
    @population_size.times do
      population << @chromosome.seed
    end
  end

  def selection
    @population.sort! { |a, b| b.fitness <=> a.fitness}
    best_fitness = @population[0].fitness
    worst_fitness = @population.last.fitness
    acum_fitness = 0
    if best_fitness-worst_fitness > 0
      @population.each do |chromosome|
        chromosome.normalized_fitness = (chromosome.fitness - worst_fitness)/
          (best_fitness-worst_fitness)
        acum_fitness += chromosome.normalized_fitness
      end
    else
      @population.each { |chromosome| chromosome.normalized_fitness = 1 }
    end
    selected_to_breed = []
    ((2 * @population_size) / 3).times do
      selected_to_breed << select_random_individual(acum_fitness)
    end
    selected_to_breed
  end

  def reproduction(selected_to_breed)
    offsprings = []
    0.upto(selected_to_breed.length/2-1) do |i|
      offsprings << @chromosome.reproduce(selected_to_breed[2*i],
                                          selected_to_breed[2*i+1])
    end
    @population.each do |individual|
      @chromosome.mutate(individual)
    end
    return offsprings
  end

  def replace_worst_ranked(offsprings)
    size = offsprings.length
    @population = @population [0..((-1*size)-1)] + offsprings
  end

  def best_chromosome
    the_best = @population[0]
    @population.each do |chromosome|
      the_best = chromosome if chromosome.fitness > the_best.fitness
    end
    return the_best
  end

  private

  def select_random_individual(acum_fitness)
    select_random_target = acum_fitness * rand
    local_acum = 0
    @population.each do |chromosome|
      local_acum += chromosome.normalized_fitness
      return chromosome if local_acum >= select_random_target
    end
  end
end
