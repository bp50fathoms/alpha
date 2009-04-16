require 'forwardable'
require 'property'


class Property
  extend SingleForwardable

  def self.properties; @@properties ||= {} end

  def_delegators :properties, :[], :clear, :has_key?, :keys, :values

  def self.method_missing(name, *args)
    if properties.has_key?(name)
      narg = args.size
      arity = properties[name].arity
      if narg != arity
        raise ArgumentError, "wrong number of arguments (#{narg} for #{arity})"
      end
      properties[name].call(*args)
    else
      super
    end
  end

  def self.respond_to?(name, include_private = false)
    properties.has_key?(name) ? true : super
  end

  @@next_desc = nil

  def self.next_desc=(doc)
    @@next_desc = Property.check_desc(doc)
  end

  attr_reader :desc

  def desc=(doc)
    raise 'Description already set' unless @desc.nil?
    @desc = Property.check_desc(doc)
  end

  private

  def self.[]=(key, property)
    properties[key] = property
    if @@next_desc
      property.desc = @@next_desc
      @@next_desc = nil
    end
    property
  end

  def self.check_desc(doc)
    raise ArgumentError, 'the description must be a String' unless
      doc.is_a?(String)
    doc
  end
end
