require 'resultcollector'


module ResultCollectorSpec
  describe ResultCollector do
    it 'should collect ' do
      # (a | (b | (c >= d)))
      # (| a (| b (>= c d)))
      l = lambda { |rc,a,b,c,d| rc.store(:e1, :|, rc.store_obj(:e2, a),
                                         rc.store(:e3, :|, rc.store_obj(:e4, b),
                                                  rc.store(:e5, :>=,
                                                           rc.store_obj(:e6, c),
                                                           rc.store_obj(:e7, d)))) }
      rc = ResultCollector.new
      l.call(rc, true, false, 4.0, 5.0).should be_true
      rc.result[:e1].should be_true
      rc.result[:e2].should be_true
      rc.result[:e3].should be_false
      rc.result[:e4].should be_false
      rc.result[:e5].should be_false
      rc.result[:e6].should == 4.0
      rc.result[:e7].should == 5.0
    end
  end
end
