# Source: http://raganwald.com/source/dsl_and_let.html
# Dependency of the pattern matching library for Ruby
# Does not have anything to do with the DSLs employed in the rest of the project

class DomainSpecificLanguage

  # See http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html

  def metaclass; class << self; self; end; end
  def meta_eval &blk; metaclass.instance_eval &blk; end

  # Adds methods to a metaclass
  def meta_def name, &blk
    meta_eval { define_method name, &blk }
  end

  # See http://onestepback.org/index.cgi/Tech/Ruby/RubyBindings.rdoc

  class ReadOnlyReference
    def initialize(var_name, vars)
      @getter = eval "lambda { #{var_name} }", vars
    end
    def value
      @getter.call
    end
  end

  attr_reader :outer_binding, :outer_self

  # instances of a DomainSpecificLanguage are created each time
  # a block is evaluated with that language. The instance is
  # intialized with the block's binding.

  def initialize(given_binding)
    @outer_binding = given_binding
    @outer_self = ReadOnlyReference.new(:self, given_binding)
  end

  # some jiggery-pokery to access methods defined in the block's
  # scope, because when the block is evaluated with the DomainSpecificLanguage,
  # we use #instance_eval to set <tt>self</tt> to the DomainSpecificLanguage
  # instance.
  def method_missing(symbol, *args, &block)
    if args.empty?
      r = ReadOnlyReference.new(symbol, outer_binding)
      meta_def(symbol) { r.value }
      r.value
    else
      outer_self.value.send symbol, *args, &block
    end
  end

  class << self

    # Evaluates a block in the context of a new DomainSpecificlanguage
    # instance.
    def eval &block
      new(block.binding).instance_eval(&block)
    end

  end

end

# We open Kernel and add just one method for introducing DomainSpecificLanguages

module Kernel

  # Evaluate a block with a DomainSpecificLanguage

  def with dsl_class, &block
    dsl_class.eval(&block)
  end

end

# Let is a DomainSpecificLanguage that actually creates DomainSpecificLanguages.
#
# Let works a lot like <tt>let</tt> in Scheme. Your provide a hash of names and value
# expressions. The value expressions are evaluated in the outer scope, and then we have
# a little domain specific language wher ethe inner scope has the names all bound to the
# values. E.g.
# <tt>
# with Let do
#     let :x => 100, :y => 50 do
#         print "#{x + y} should equal fifty"
#     end
# end
# </tt>
#
# Within the Let DomainSpecificLanguage, you can declare multiple <tt>let</tt> statements and nest
# them as you please.
#
# One important limitation: you cannot bind a value to a name that is already a local variable.

class Let < DomainSpecificLanguage

  class Scope < DomainSpecificLanguage

    # initializes a Scope. In addition to the outer binding, we also pass in the
    # hash of names and values. Note the check to ensure we are not trying to
    # override a lcoal variable.

    def initialize given_binding, let_clauses = {}
      let_clauses.each do |symbol, value|
        var_name = symbol.to_s
        raise ArgumentError.new("Cannot override local #{var_name}") if eval("local_variables", given_binding).detect { |local| local == var_name  }
        meta_eval { attr_accessor(var_name) }
        send "#{var_name}=", value
      end
      super(given_binding)
    end

  end

  # Define a new Scope: you're really defining a new DomainSpecificLanguage

  def let let_clauses = {}, &block
    Scope.new(block.binding, let_clauses).instance_eval(&block)
  end

  class << self

    # If you just want a one-off
    # def eval let_clauses = {}, &block
    #   Scope.new(block.binding, let_clauses).instance_eval(&block)
    # end

  end

end

# A DomainSpecificDelegator is a DSL that delegates methods to a class or object.
# The main use is to separate the mechanics of scoping from the methods of a utility
# class.

class DomainSpecificDelegator < DomainSpecificLanguage

  class << self

    # insert one or more #delegate_to calls in the class definition, giving a receiver
    # and a hash. Each hash pair is of the form <tt>verb => method</tt> where verb is the
    # name you will use in the DSL and method is the method in the receiver that will handle
    # it.
    def delegate_to receiver, method_hash
      @@delegations ||= {}
      method_hash.each { |verb, method_name| @@delegations[verb.to_s] = [receiver, method_name.to_s] }
    end

  end

  def method_missing symbol, *args, &block
    receiver, method_name = *@@delegations[symbol.to_s]
    if receiver
      receiver.send method_name, *args, &block
    else
      super(symbol, *args, &block)
    end
  end

end
