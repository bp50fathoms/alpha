module UIProtocol
  def update(key, value = nil)
    params = value ? [value] : []
    self.send(key, *params)
  end
end
