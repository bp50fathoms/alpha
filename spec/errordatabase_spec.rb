require 'errordatabase'
require 'fileutils'
require 'property_helpers'


module ErrorDatabaseSpec
  describe ErrorDatabase do
    include PropertyHelpers

    DB_FILE = 'errors.db'

    it_should_behave_like 'Property'

    after(:each) do
      begin
        FileUtils::rm(DB_FILE)
      rescue Errno::ENOENT; end
    end

    it "should create the schema when the database file doesn't exist" do
      db = ErrorDatabase.new(DB_FILE)
      db.driver.execute('SELECT * FROM error')
    end

    it 'should not create the schema when it already exists' do
      db = ErrorDatabase.new(DB_FILE)
      p = property :a => String do |a|
        a.size == a.length
        end
      d = Marshal.dump(['a'])
      db.driver.execute("INSERT INTO error VALUES ('p1', '#{d}', 0.5)")
      db2 = ErrorDatabase.new(DB_FILE)
      r = db.driver.execute('SELECT * FROM error')
      Marshal.load(r.first[1]).should == ['a']
    end

    it 'should create the schema when the database file but not the
    tables exist' do
      db = ErrorDatabase.new(DB_FILE)
      db.driver.execute('DROP TABLE error')
      db2 = ErrorDatabase.new(DB_FILE)
      db2.driver.execute('SELECT * FROM error')
    end

    it 'should insert errors correctly when they do not exist' do
      db = ErrorDatabase.new(DB_FILE)
      p = property :p1 => [Fixnum, String] do |a,b| true end
      db.insert_error(p, [1, 'ab'])
      db.driver.execute('SELECT * FROM error').should ==
        [['p1', Marshal.dump([1, 'ab']), 1.0]]
    end

    it 'should not insert successful cases unless they are failures' do
      p1 = property :p1 => [String] do |a| true end
      p2 = property :p2 => [String] do |a| true end
      db = ErrorDatabase.new(DB_FILE)
      db.get_cases(p1).should == []
      db.insert_success(p1, ['a'])
      db.insert_success(p1, ['b'])
      db.update_property(p1)
      db.get_cases(p1).should == []
      db.insert_error(p1, ['c'])
      db.get_cases(p1).should == [['c']]
      db.update_property(p1)
      db.driver.execute("SELECT * FROM error").map do |e|
        e[1] = Marshal.load(e[1])
        e
      end.should == [['p1', ['c'], 1.0]]
      db.update_property(p2)
      db.insert_error(p2, ['d'])
      db.insert_success(p1, ['c'])
      db.update_property(p1)
      db.driver.execute("SELECT * FROM error ORDER BY property").map do |e|
        e[1] = Marshal.load(e[1])
        e
      end.should == [['p1', ['c'], 0.4], ['p2', ['d'], 1.0]]
    end

    it 'should work fine in a complete scenario' do
      db = ErrorDatabase.new(DB_FILE)
      p1 = property :p1 => [String] do |a| a.length == 0 end
      p2 = property :p2 => [String, String] do |a,b| a == b end
      db.insert_success(p1, ['a'])
      db.insert_success(p1, ['b'])
      db.update_property(p1)
      db.insert_success(p2, ['a', 'b'])
      db.update_property(p2)
      db.insert_success(p1, ['a'])
      db.insert_error(p1, ['b'])
      db.insert_success(p2, ['a', 'b'])
      db.insert_error(p2, ['c', 'd'])
      db.insert_success(p1, ['a'])
      db.insert_success(p1, ['b'])
      db.update_property(p1)
      db.update_property(p2)
      db.update_property(p1)
      db.driver.execute("SELECT * FROM error ORDER BY property").map do |e|
        e[1] = Marshal.load(e[1])
        e
      end.should == [['p1', ['b'], 0.76], ['p2', ['c', 'd'], 1.0]]
    end

    it 'should return the failing cases ordered correctly and unmarshalled' do
      p = property :p1 => [Fixnum, String] do |a,b| true end
      db = ErrorDatabase.new(DB_FILE)
      c1 = [123, 'abc']
      m1 = Marshal.dump(c1)
      db.driver.execute("INSERT INTO error VALUES ('p1', '#{m1}', 0.5)")
      c2 = [245, 'cde']
      m2 = Marshal.dump(c2)
      db.driver.execute("INSERT INTO error VALUES ('p1', '#{m2}', 1)")
      db.get_cases(p).should == [c2, c1]
    end
  end
end
