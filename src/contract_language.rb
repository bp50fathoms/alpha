require 'contract'


class Class
  def contract(signature, &block)
    signature = Signature::dump_signature(signature)
    method = instance_method(signature.first)
    Contract.new(method, signature.last, &block)
  end
end
