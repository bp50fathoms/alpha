require 'random'
require 'set'


module RandomStringSpec
  describe String do
    it 'should generate strings with the indicated frequency when of is used' do
      gen = String.of(0, 0, 1, 0)
      set = Set[]
      100.times { set << gen.arbitrary }
      r = (0..9).to_a
      set.all? do |e|
        e.split('').all? { |c| r.include?(c.to_i) }
      end.should be_true
    end
  end
end
