require 'random'
require 'set'


module RandomSpec
  describe Random do
    include Random

    it 'frequency should only generate values in the provided hash' do
      gen = frequency({ 5 => 2, 6 => 1})
      set = Set[]
      five = 0
      six = 0
      100.times do
        g = gen.arbitrary
        set << g
        if g == 5
          five += 1
        elsif g == 6
          six += 1
        end
      end
      set.to_a.sort.should == [5, 6]
      five.should > six
    end

    it 'one_of should only generate values in the provided list' do
      gen = one_of(1..5, 70)
      set = Set[]
      100.times { set << gen.arbitrary }
      set.to_a.sort.should == (1..5).to_a + [70]
    end

    it 'both combinators should work for compound generators and types' do
      gen = frequency(one_of(1..20) => 5, String => 1, [] => 2)
      set = Set[]
      1000.times { set << gen.arbitrary }
      r = (1..20).to_a
      set.all? do |e|
        r.include?(e) or e.is_a?(String) or e == []
      end.should be_true
    end
  end
end
