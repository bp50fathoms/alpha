require 'property'
require 'rubygems'
require 'ruby2ruby'
require 'parse_tree'
require 'parse_tree_extensions'


class PropertyVisitor < SexpProcessor
  def self.proc(block)
    ncode = Ruby2Ruby.new.process(self.new.proc_body(block.to_sexp))
    block.binding.eval(ncode)
  end

  def proc_body(exp)
    exp.shift
    call = exp.shift
    asgn = exp.shift
    raise 'Empty property body' if exp.empty?
    s(:iter, call, add_arg(asgn), exp.shift)
  end

  # protected

  # def process_lvar(exp)
  #   exp.shift
  #   exp.shift
  #   s()
  # end

  # def process_call(exp)
  #   while !exp.empty?
  #     exp.shift
  #   end
  #   s()
  # end

  private

  def add_arg(asgn)
    param = s(:lasgn, :_r)
    if asgn[0] == :lasgn
      s(:masgn, s(:array, asgn, param))
    else
      asgn[1] << param
      asgn
    end
  end
end
