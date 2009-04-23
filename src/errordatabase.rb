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
      p = probability(property, tcase)
      update(property, tcase, alpha + (1 - alpha) * p)
    end
    update_property(property, tcase)
  end

  def update_property(property, error = nil)
    e = dump(error)
    @driver.execute('SELECT * FROM error WHERE property = ?', property.key) do |e|
      if @suc.include?(e[1])
        update_dump(property, e[1], new_prob(0, e[2]))
      elsif e[1] != e
        update_dump(property, e[1], new_prob(1, e[2]))
      end
    end
    @suc = Set[]
  end

  def get_cases(property)
    @driver.execute('SELECT tcase FROM error WHERE property = ? ' +
                    'ORDER BY probability DESC', property.key).map do |e|
      Marshal.load(e.first)
    end
  end

  private

  def new_prob(h, old_prob)
    alpha * h + (1 - alpha) * old_prob
  end

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
    @ins ||= @driver.prepare('INSERT INTO error(property, tcase, probability) ' +
                             'VALUES (?, ?, ?)')
    @ins.execute(property.key, Blob.new(dump(tcase)), prob)
  end

  def update(property, tcase, prob)
    update_dump(property, tcase, dump(prob))
  end

  def update_dump(property, tcase, prob)
    @upd ||= @driver.prepare('UPDATE error SET probability = ? WHERE ' +
                             'property = ? and tcase = ?')
    @upd.execute(prob, property.key, Blob.new(tcase))
  end

  def count_error(property, tcase)
    @driver.get_first_row('SELECT COUNT(*) FROM error WHERE ' +
                        'property = ? and tcase = ?', property.key,
                          Blob.new(dump(tcase))).first.to_i
  end

  def probability(property, tcase)
    @driver.get_first_row("SELECT probability FROM error WHERE " +
               "property = ? and tcase = ?", property.key,
                          Blob.new(dump(tcase))).first
  end
end
