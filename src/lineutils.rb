module LineUtils
  def divide(string, x)
    [string[0..x - 1], string[x..-1] || '']
  end

  def full_wide(line, x)
    l = line.delete("\n")
    ll = l.length
    raise ArgumentError, 'line too big' if ll > x
    l = l + ' ' * (x - ll) if ll < x
    l
  end
end
