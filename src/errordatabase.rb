require 'property'
require 'rubygems'
require 'set'
require 'sqlite3'


class ErrorDatabase
  attr_reader :alpha, :driver

  def initialize(file, alpha = 0.6)
    @alpha = alpha
    @driver = SQLite3::Database.new(file, :type_translation => true)
    create_schema
    @suc = Set[]
  end

  def insert_success(property, tcase)
    @suc << Marshal.dump(tcase)
  end

  def insert_error(property, tcase)
    k = property.key.to_s
    m = Marshal.dump(tcase)
    where = "WHERE property='#{k}' and tcase='#{m}'"
      c = @driver.get_first_row("SELECT COUNT(*) FROM error #{where}").first.to_i
    if c == 0
      @driver.execute("INSERT INTO error VALUES ('#{k}', '#{m}', 1)")
    else
      p = @driver.get_first_row("SELECT probability FROM error #{where}").first
      p = alpha + (1 - alpha ) * p
      @driver.execute("UPDATE error SET probability=#{p} #{where}")
    end
    update_property(property, tcase)
  end

  def update_property(property, error = nil)
    e = Marshal.dump(error)
    @driver.execute("SELECT * FROM error WHERE property='#{property.key}'") do |e|
      if @suc.include?(e[1])
        h = 0
        p = alpha * h + (1 - alpha) * e[2]
        @driver.execute("UPDATE error SET probability=#{p} WHERE " +
                        "property='#{property.key}' and tcase='#{e[1]}'")
      elsif e[1] != e
        h = 1
        p = alpha * h + (1 - alpha) * e[2]
        @driver.execute("UPDATE error SET probability=#{p} WHERE " +
                      "property='#{property.key}' and tcase='#{e[1]}'")
      end
    end
    @suc = Set[]
  end

  def get_cases(property)
    @driver.execute("SELECT tcase FROM error WHERE property = '#{property.key}' " +
                    'ORDER BY probability DESC').map { |e| Marshal.load(e.first) }
  end

  private

  def create_schema
    sql =
<<SQL
      CREATE TABLE IF NOT EXISTS error(
        property VARCHAR(16),
        tcase BLOB,
        probability REAL NOT NULL,
        PRIMARY KEY (property, tcase)
      );
SQL
    @driver.execute_batch(sql)
  end
end
