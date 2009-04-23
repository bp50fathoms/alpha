require 'forwardable'


module PipelineElement
  def |(other)
    other.pipe = self
    other
  end
end


module Filter
  extend Forwardable
  include PipelineElement

  attr_accessor :pipe

  def_delegator :@pipe, :output, :input

  def output
    i = input
    process(i) unless i.nil?
  end
end
