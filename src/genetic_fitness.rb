module GeneticFitness
  MAXFIT = 1e6

  FUNC = {
    :< => { true => lambda { |a,b| a < b ? 0 : a - b + 1 },
      false => lambda { |a,b| a < b ? b - a : 0 } },

    :<= => { true => lambda { |a,b| a <= b ? 0 : a - b },
      false => lambda { |a,b| a <= b ? b - a + 1 : 0 } },

    :== => { true => lambda { |a,b| a == b ? 0 : (b - a) ** 2 },
      false => lambda { |a,b| a == b ? (1 + (b - a) ** 2) * 1e-1 : 0 } },

    :> => { true => lambda { |a,b| FUNC[:<][true].call(b,a) },
      false => lambda { |a,b| FUNC[:<][false].call(b,a) } },

    :>= => { true => lambda { |a,b| FUNC[:<=][true].call(b,a) },
      false => lambda { |a,b| FUNC[:<=][false].call(b,a) } },

    :atom => { true => lambda { |a| a ? 0 : MAXFIT },
      false => lambda { |a| a ? MAXFIT : 0 } }
    }


  def fitness(op, goal, *args)
    FUNC[op][goal].call(*args)
  end

  module_function :fitness
end
