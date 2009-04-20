require 'pipeline'
require 'set'


class PList < Array
  include PipelineElement

  def initialize(enum = nil)
    super
  end

  def output
    self
  end
end
