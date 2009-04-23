require 'forwardable'
require 'initializer'


module Action
  class Action
    def self.new(&block)
      raise ArgumentError, 'a block needs to be suplied' unless block
      raise ArgumentError, 'wrong block arity' if block.arity > 1
      if block.arity == 1
        IAction.new(block)
      else
        SAction.new(block)
      end
    end


    class SAction
      extend Forwardable
      include PipelineElement

      initialize_with :block

      def_delegator :@block, :call, :output
    end


    class IAction
      include Filter

      initialize_with :block

      def process(input)
        @block.call(input)
      end
    end
  end


  def do!(&block)
    Action.new(&block)
  end
end
