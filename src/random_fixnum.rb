class Fixnum
  def self.arbitrary
    r = rand(1e6)
    s = rand(2) == 0 ? 1 : -1
    r * s
  end
end
