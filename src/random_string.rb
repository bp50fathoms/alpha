class String
  extend Random

  @@alphabet = one_of(65..90, 97..122)
  @@control = one_of(0..32, 177)
  @@number = one_of(48..57)
  @@special = one_of(33..47, 58..64, 91..96, 123..126)


  class StringGenerator
    def initialize(length, char)
      @length = length
      @char = char
    end

    def arbitrary
      s = ''
      @length.arbitrary.times { s += @char.arbitrary.chr }
      s
    end
  end


  CHAR_F = { @@alphabet => 200, @@control => 1, @@number => 50, @@special => 1 }
  @@gen = StringGenerator.new(one_of(0..5), frequency(CHAR_F))

  def self.arbitrary
    @@gen.arbitrary
  end

  def self.of(a, c, n, s)
    of_f = { @@alphabet => a, @@control => c, @@number => n, @@special => s }
    StringGenerator.new(length = one_of(0..5), frequency(of_f))
  end
end
