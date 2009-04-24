require 'historic'
require 'strategy_helpers'


module HistoricStrategySpec
  describe HistoricStrategy do
    def strategy; HistoricStrategy end

    DB_FILE = 'errors.db'

    describe HistoricStrategy, 'when just built' do
      it_should_behave_like 'NewStrategy'
    end


    describe HistoricStrategy, 'with runner and database' do
      before(:each) do
        Property.clear
        delete_file
        @db = ErrorDatabase.new(DB_FILE)
        @p1 = property :p1 => [String] do |a| a.length == 0 end
        @p2 = property :p2 => [String, String] do |a,b| a == b end
        @p3 = property :p3 => [String] do |a| true end
        @db.insert_success(@p1, ['a'])
        @db.update_property(@p1)
        @db.insert_success(@p1, ['b'])
        @db.insert_error(@p1, ['a'])
        @db.insert_success(@p1, ['a'])
        @db.insert_error(@p1, ['b'])
        @db.insert_success(@p2, ['a', 'b'])
        @db.update_property(@p1)
        @db.insert_success(@p1, ['a'])
        @db.insert_success(@p1, ['b'])
        @db.update_property(@p1)
        @db.insert_error(@p1, ['b'])
        @db.insert_error(@p2, ['a', 'b'])
        @strategy = strategy.new
        @strategy.set_runner(stub('Runner', :db => @db))
        @strategy.set_property(define_prop)
      end

      after(:each) do
        @strategy = @db = nil
        delete_file
        Property.clear
      end

      def delete_file
        begin
          FileUtils::rm(DB_FILE)
        rescue Errno::ENOENT; end
      end


      describe HistoricStrategy, 'with a property that does not have any' do
        it_should_behave_like 'PropertyWithoutCases'

        def define_prop; @p3 end
      end


      describe HistoricStrategy, 'with a property that has one case' do
        it_should_behave_like 'PropertyWithCases'

        def define_prop; @p2 end

        it '' do
          @strategy.generate.should == ['a', 'b']
          @strategy.progress.should == 1.0
          @strategy.exhausted?.should be_true
        end
      end


      describe HistoricStrategy, 'with a property that has many cases' do
        it_should_behave_like 'PropertyWithCases'

        def define_prop; @p1 end

        it '' do
          @strategy.generate.should == ['b']
          # @strategy.progress.should == 0.5
          @strategy.exhausted?.should be_false
          @strategy.generate.should == ['a']
          # @strategy.progress.should == 1.0
          @strategy.exhausted?.should be_true
        end
      end
    end
  end
end
