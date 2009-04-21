require 'runner'
require 'cases'


class SimpleRunner < SequentialRunner
  def initialize
    @cases = CasesStrategy.new
  end

  private

  def check_property(p)
    @cases.set_property(p)
    unless @cases.exhausted?
      failed = false
      while !@cases.exhausted? and !failed
        notify_step
        failed = !eval_property(p, @cases.generate)
      end
      notify_success unless failed
    else
      notify_failure('No test cases could be generated')
    end
  end
end
