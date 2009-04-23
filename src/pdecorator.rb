require 'decorator'
require 'property'


class PropertyDecorator
  include Decorator

  attr_reader :property, :cover_table

  attr_accessor :falsifying_case

  def initialize(property)
    @property = property
    @cover_table = CoverTable.new(property)
    @falsifying_case = nil
  end

  def falsified?
    !falsifying_case.nil?
  end
end
