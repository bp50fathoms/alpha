class Default; end


module Initializer
  def initsuper_with(p, s, &rest)
    defaults = []
    filter_default(p, defaults)
    filter_default(s, defaults)
    params = p + s
    define_method(:initialize) do |*args|
      raise ArgumentError if args.size + defaults.size < params.size
      args += defaults.last(params.size - args.size) if args.size < params.size
      ap = args.first(p.size)
      as = args - ap
      super(*as) if defined?(super)
      p.zip(ap) { |param, arg| instance_variable_set("@#{param}", arg) }
      instance_eval(&rest) unless rest.nil?
    end
    return p
  end

  def filter_default(a, d)
    a.each_with_index do |e,i|
      if e.is_a?(Default)
        a[i] = e.name
        d << e.value
      end
    end
  end

  def initialize_with(*params, &rest)
    initsuper_with(params, [], &rest)
  end

  def attrs(*params, &rest)
    attr_accessor *initialize_with(*params, &rest)
  end
end


class Class
  include Initializer
end


class Default
  attrs :name, :value

  def self.[](*ary)
    Default.new(ary[0], ary[1])
  end
end
