# Source: http://blog.pretheory.com/pattern_match.rb
# Pattern matching (as in functional programming) implementation for Ruby

require 'dsl'

# module Matchable

def lit(obj)
  Literal.new(obj)
end

def pmatch(args,&block)
  pm = PatternMatch.new(args,block.binding)
  pm.instance_eval(&block)
  pm.value
end

class PatternMatch < Let::Scope

  def initialize(args,binding)
    @args = args
    super(binding)
  end

  def with(pattern, &block)
    args = @args
    unless @matched
      mapping = {}
      if(pattern.patmatch(args,mapping))
        @matched = true
        if(mapping.length > 0)
          @value = Kernel.with(Let){let(mapping,&block)}
        else
          @value = block.call
        end
      end
    end
  end

  def otherwise(&by_default)
    @by_default = by_default
  end

  def value
    if (@matched)
      @value
    else
      if(@by_default)
        @by_default.call
      else
        raise NoMatchFoundError, "The arguments did not match any of the supplied patterns and no otherwise clause was provided"
      end
    end
  end

end

class NoMatchFoundError < StandardError; end

#end

class Object
  def patmatch(arg,mapping)
    self == arg
  end
end

class Class
  def patmatch(arg,mapping)
    arg.is_a?(self)
  end
end

class Symbol

  def patmatch(arg,mapping)
    if(empty?)
      true
    else
      mapping[self] = arg unless mapping.nil?
      true
    end
  end

  def empty?
    self.to_s=="_"
  end

  def %(other)
    raise ArgumentError unless other.is_a?(Symbol)
    Destructurer.new(self,other)
  end

  def &(other)
    Namer.new(self,other)
  end

end

class Namer

  def initialize(sym, obj)
    @sym = sym
    @obj = obj
  end

  def patmatch(args,mapping)
    if(@obj.patmatch(args,mapping))
      mapping[@sym] = args
      true
    else
      false
    end
  end

end

class Destructurer

  def initialize(*names)
    @names = names
  end

  def patmatch(args,mapping)
    return false unless args.is_a?(Array)
    return false unless args.length>0
    @names[0...-1].each do |name|
      mapping[name]=args.shift
    end
    mapping[@names.last] = args
    true
  end

  def %(symbol)
    raise ArgumentError unless symbol.is_a?(Symbol)
    @names << symbol
    self
  end

end

module Enumerable

  def patmatch(args,mapping)
    return false if self.length != args.length || !args.is_a?(Enumerable)
    return self.zip(args).all? {|x_y| x_y[0].patmatch(x_y[1],mapping)}
  end

end

class String

  def patmatch(args,mapping)
    return self==args
  end

end

class Literal

  def initialize(obj)
    @obj = obj
  end

  def patmatch(args,mapping)
    @obj == args
  end

end
