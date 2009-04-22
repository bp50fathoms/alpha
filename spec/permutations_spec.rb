require 'permutations'


module PermutationsSpec
  describe 'genc' do
    it 'should generate correct permutation code' do
      code = Permutations.genc(2, lambda { |v,i| "for #{v} in 1..2"}, ',',
                               lambda{|y| "a << [#{y}]"})
      a = []
      eval code, binding
      a.should == [[1, 1], [1, 2], [2, 1], [2, 2]]
    end
  end
end
