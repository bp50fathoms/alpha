require 'exhaustive'
require 'set'


module ExhaustiveCombinatorsSpec
  describe Exhaustive do
    include Exhaustive

    it 'should compute all pairs of strings of size 0 correctly' do
      product(String, String).exhaustive(0).entries.should == [['', '']]
    end

    it 'should compute all pairs of strings of size 1 correctly' do
      strs = product(String, String).exhaustive(1).entries.to_set
      strs.size.should == 128 ** 2
      strs.each { |s| s.size.should == 2 }
    end

    it 'should compute correctly the union' do
      union(product(String, String), String).exhaustive(1).entries.size.should ==
        128 ** 2 + 128
    end
  end
end
