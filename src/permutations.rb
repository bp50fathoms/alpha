module Permutations
  def genc(n, head, op, yld)
    v = '_a00'
    command = ''
    vars = []
    for i in 0..n-1
      command += head.call(v, i) + "\n"
      vars << v
      v = v.next
    end
    y = vars.inject('') { |s,e| s += e + op }[0..-2]
    command += yld.call(y) + "\n"
    for i in 0..n-1
      command += "end\n"
    end
    command
  end

  module_function :genc
end
