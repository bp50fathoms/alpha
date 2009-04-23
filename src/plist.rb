require 'pdecorator'
require 'pipeline'
require 'set'


class PList < Array
  include PipelineElement

  def self.all
    self.new(Property.values)
  end

  def initialize(enum = nil)
    super(enum.map { |e| PropertyDecorator.new(e) })
  end

  def output
    self
  end
end
