require 'resultcollector'


module ResultCollectorSpec
  describe ResultCollector do
    it 'should collect ' do
      # (a | (b | (c >= d)))
      # (| a (| b (>= c d)))
      l = lambda do |a,b,c,d,r|
        r.store(1, r.store(2, a) | r.store(3, r.store(4, b) |
                                           r.store(5, r.store(6, c) >=
                                                   r.store(7,d))))
      end
      r = ResultCollector.new
      l.call(true, false, 4.0, 5.0, r).should be_true
      r.result[1].should == [true]
      r.result[2].should == [true]
      r.result[3].should == [false]
      r.result[4].should == [false]
      r.result[5].should == [false]
      r.result[6].should == [4.0]
      r.result[7].should == [5.0]
    end
  end
end
