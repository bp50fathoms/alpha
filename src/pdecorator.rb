require 'decorator'
require 'property'


class PropertyDecorator
  include Decorator

  attr_reader :property, :cover_table

  attr_accessor :falsified

  def initialize(property)
    @property = property
    @cover_table = CoverTable.new(property)
    @falsified = false
  end
end
