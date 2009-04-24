module ContractUtils
  def send_with_old(object, method, *args)
    old = object.clone
    r = object.send(method, *args)
    [r, old]
  end

  module_function :send_with_old
end
