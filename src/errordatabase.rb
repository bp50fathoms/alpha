require 'property'
require 'rubygems'
require 'set'
require 'sqlite3'


class ErrorDatabase
  include SQLite3, Marshal

  attr_reader :alpha, :driver

  def initialize(file, alpha = 0.6)
    @alpha = alpha
    @driver = Database.new(file, :type_translation => true)
    create_schema
    @suc = Set[]
  end

  def insert_success(property, tcase)
    @suc << dump(tcase)
  end

  def insert_error(property, tcase)
    c = count_error(property, tcase)
    if c == 0
      insert(property, tcase, 1)
    else
      # p = @driver.get_first_row("SELECT probability FROM error #{where}").first
      p = probability(property, tcase)
      p = alpha + (1 - alpha ) * p
      update(property, tcase, p)
    end
    update_property(property, tcase)
  end

  def update_property(property, error = nil)
    e = dump(error)
    @driver.execute("SELECT * FROM error WHERE property='#{property.key}'") do |e|
      if @suc.include?(e[1])
        h = 0
        p = alpha * h + (1 - alpha) * e[2]
        update_dump(property, e[1], p)
      elsif e[1] != e
        h = 1
        p = alpha * h + (1 - alpha) * e[2]
        update_dump(property, e[1], p)
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

  def insert(property, tcase, prob)
    @driver.execute("INSERT INTO error VALUES ('#{property.key}', '#{dump(tcase)}', #{prob})")
    # @driver.execute('INSERT INTO error VALUES (?, ?, ?)', property.key.to_s,
     #               Blob.new(dump(tcase)), prob)
  end

  def update(property, tcase, prob)
    update_dump(property, tcase, dump(prob))
  end

  def update_dump(property, tcase, prob)
    @driver.execute("UPDATE error SET probability=#{prob} WHERE " +
                    "property='#{property.key}' and tcase='#{tcase}'")
  end

  def count_error(property, tcase)
    @driver.get_first_row("SELECT COUNT(*) FROM error WHERE " +
                          "property='#{property.key}' and tcase='#{dump(tcase)}'").first.to_i
  end

  def probability(property, tcase)
    @driver.get_first_row("SELECT probability FROM error WHERE " +
               "property='#{property.key}' and tcase='#{dump(tcase)}'").first
  end
end
