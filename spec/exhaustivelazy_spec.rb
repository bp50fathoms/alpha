require 'exhaustive'


module ExhaustiveLazySpec
  describe Enumerable do
    it 'should filter values lazily' do
      t1 = Time.new
      r = 1..1_000_000_000
      e = r.lazy_apply { |y,e| y[e] if e % 2 == 0 }
      e.enum_for.next.should == 2
      t2 = Time.new
      (t2 - t1).should < 1e-2
    end

    it 'should map values lazily' do
      t1 = Time.new
      r = 1..1_000_000_000
      e = r.lazy_apply { |y,e| y[e + 100] }
      e.enum_for.next.should == 101
      t2 = Time.new
      (t2 - t1).should < 1e-2
    end
  end
end
