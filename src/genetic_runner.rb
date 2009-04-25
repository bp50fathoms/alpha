require 'genetic_search'
require 'initializer'
require 'permutations'
require 'runner'


class GeneticRunner < SequentialRunner
  initialize_with(Default[:population, 10], Default[:generations, 100])

  private

  def check_property(p)
    # si propiedad no tiene todos param fixnum
      # buscar hojas de propiedad
      # iterar por todas las combinaciones de true false
        # crear search con chromosome adecuado a combinacion y hojas, lanzar
        # desde alli utilizar excepcion para retornar en caso de que falle
    # en caso contrario fallar

    if p.types.all? { |t| t == Fixnum }
      l = leafs(p.tree)
      code = Permutations.genc(l.size, lambda { |v,i| "for #{v} in [true,false]"},
                               ',', lambda{ |y| "a << [#{y}]" })
      a = []
      eval code, binding
      a.each do |c|

      end
    else
      notify_failure('No test cases could be generated')
    end
  end
end
