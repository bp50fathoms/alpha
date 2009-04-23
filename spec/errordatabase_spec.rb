require 'errordatabase'
require 'fileutils'
require 'property_helpers'


module ErrorDatabaseSpec
  include SQLite3

  describe ErrorDatabase do
    it_should_behave_like 'Property'

    DB_FILE = 'errors.db'

    before(:each) do
      delete_file
      @db = ErrorDatabase.new(DB_FILE)
    end

    after(:each) do
      @db = nil
      delete_file
    end

    it "should create the schema when the database file doesn't exist" do
      @db.driver.execute('SELECT * FROM error')
    end

    it 'should not create the schema when it already exists' do
      p = property :a => String do |a|
        a.size == a.length
        end
      d = Marshal.dump(['a'])
      @db.driver.execute("INSERT INTO error VALUES ('p1', '#{d}', 0.5)")
      db2 = ErrorDatabase.new(DB_FILE)
      select_ord.should == [['p1', ['a'], 0.5]]
    end

    it 'should create the schema when the database file but not the tables exist' do
      @db.driver.execute('DROP TABLE error')
      db2 = ErrorDatabase.new(DB_FILE)
      db2.driver.execute('SELECT * FROM error')
    end

    it 'should insert errors correctly when they do not exist' do
      p = property :p1 => [Fixnum, String] do |a,b| true end
      @db.insert_error(p, [1, 'ab'])
      select_ord.should == [['p1', [1, 'ab'], 1.0]]
    end

    it 'should not insert successful cases unless they are failures' do
      p1 = property :p1 => [String] do |a| true end
      p2 = property :p2 => [String] do |a| true end
      @db.get_cases(p1).should == []
      @db.insert_success(p1, ['a'])
      @db.insert_success(p1, ['b'])
      @db.update_property(p1)
      @db.get_cases(p1).should == []
      @db.insert_error(p1, ['c'])
      @db.get_cases(p1).should == [['c']]
      @db.update_property(p1)
      select_ord.should == [['p1', ['c'], 1.0]]
      @db.update_property(p2)
      @db.insert_error(p2, ['d'])
      @db.insert_success(p1, ['c'])
      @db.update_property(p1)
      select_ord.should == [['p1', ['c'], 0.4], ['p2', ['d'], 1.0]]
    end

    it 'should work adequately in a complete scenario' do
      p1 = property :p1 => [String] do |a| a.length == 0 end
      p2 = property :p2 => [String, String] do |a,b| a == b end
      @db.insert_success(p1, ['a'])
      @db.insert_success(p1, ['b'])
      @db.update_property(p1)
      @db.insert_success(p2, ['a', 'b'])
      @db.update_property(p2)
      @db.insert_success(p1, ['a'])
      @db.insert_error(p1, ['b'])
      @db.insert_success(p2, ['a', 'b'])
      @db.insert_error(p2, ['c', 'd'])
      @db.insert_success(p1, ['a'])
      @db.insert_success(p1, ['b'])
      @db.update_property(p1)
      @db.update_property(p2)
      @db.update_property(p1)
      select_ord.should == [['p1', ['b'], 0.76], ['p2', ['c', 'd'], 1.0]]
    end

    it 'should deal correctly with more than one error per property' do
      p1 = property :p1 => [String] do |a| a.length == 0 end
      p2 = property :p2 => [String, String] do |a,b| a == b end
      @db.insert_success(p1, ['a'])
      @db.update_property(p1)
      @db.insert_success(p1, ['b'])
      @db.insert_error(p1, ['a'])
      @db.insert_success(p1, ['a'])
      @db.insert_error(p1, ['b'])
      @db.update_property(p1)
      @db.insert_success(p1, ['a'])
      @db.insert_success(p1, ['b'])
      @db.update_property(p1)
      select_ord.to_set.should == [['p1', ['b'], 0.4], ['p1', ['a'], 0.304]].to_set
    end

    it 'should return the failing cases ordered correctly and unmarshalled' do
      p = property :p1 => [Fixnum, String] do |a,b| true end
      c1 = [123, 'abc']
      insert('p1', c1, 0.5)
      c2 = [245, 'cde']
      insert('p1', c2, 1)
      @db.get_cases(p).should == [c2, c1]
    end

    it 'should not crash with blobs containing null sequences' do
      p = property :p1 => [String] do |a| true end
      tc = ['']
      Marshal.dump(tc).match('\000').should_not be_nil
      @db.insert_error(p, tc)
    end

    def delete_file
      begin
        FileUtils::rm(DB_FILE)
      rescue Errno::ENOENT; end
    end

    def insert(prop, tcase, pb)
      @db.driver.execute('INSERT INTO error VALUES (?, ?, ?)', prop,
                         Blob.new(Marshal.dump(tcase)), pb)
    end

    def select_ord
      @db.driver.execute('SELECT * FROM error ORDER BY property').map do |e|
        e[1] = Marshal.load(e[1])
        e
      end
    end
  end
end
