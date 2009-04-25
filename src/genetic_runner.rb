require 'genetic_search'
require 'initializer'
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
      leafs(p)
    else
      notify_failure('No test cases could be generated')
    end
  end

  def leafs(p)

  end
end
