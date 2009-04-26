require 'genetic_chromosome'
require 'genetic_search'
require 'initializer'
require 'permutations'
require 'runner'


class GeneticRunner < SequentialRunner
  include GeneticTreeLeafs

  initialize_with(Default[:population, 10], Default[:generations, 100])

  private

  def check_property(p)
    if p.types.all? { |t| t == Fixnum }
      l = leafs(p.tree)
      code = Permutations.genc(l.size, lambda { |v,i| "for #{v} in [true,false]"},
                               ',', lambda{ |y| "a << [#{y}]" })
      a = []
      eval code, binding
      success = true
      a.each do |c|
        notify_step
        factory = ChromosomeFactory.new(p, c)
        begin
          GeneticSearch.new(factory, @population, @generations).run
        rescue FalsifiedProperty => f
          failure(p, f.case)
          success = false
          break
        rescue Exception => e
          failure()
          success = false
          break
        end
      end
      notify_success if success
    else
      notify_failure('No test cases could be generated')
    end
  end
end
