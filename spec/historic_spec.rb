require 'historic'
require 'strategy_helpers'


module HistoricStrategySpec
  describe HistoricStrategy do
    def strategy; HistoricStrategy end

    describe HistoricStrategy, 'when just built' do
      include StrategyHelpers

      it_should_behave_like 'NewStrategy'
    end
  end
end
