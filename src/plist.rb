require 'set'


class PList < Array
  include PipelineElement

  def self.[](*ary)
    self.new(ary)
  end

  def self.all
    self.new(Property.values.sort { |a,b| a.key.to_s <=> b.key.to_s })
  end

  def initialize(enum)
    m = enum.map do |e|
      if e.is_a?(Property)
        PropertyDecorator.new(e)
      elsif e.is_a?(PropertyDecorator)
        e
      else
        raise ArgumentError, 'elements must be properties or decorated properties'
      end
    end
    super(m)
  end

  def select(&block)
    s = super
    s.to_plist
  end

  def output
    self
  end
end


class Array
  def to_plist
    PList.new(self)
  end
end
