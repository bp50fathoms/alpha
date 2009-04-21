require 'errordatabase'
require 'runner'
require 'set'


class ComplexRunner < SequentialRunner
  attr_reader :db

  def initialize(db, *strategies)
    @db = ErrorDatabase.new(db)
    @strategies = strategies
    @strategies.each { |s| s.set_runner(self) }
  end

  private

  def check_property(p)
    run = Set[]
    @strategies.each { |s| s.set_property(p) }
    unless @strategies.all? { |s| s.exhausted? }
      failed = false
      @time = Time.new
      while @strategies.any?{ |s| !s.exhausted? } and !failed and
          (Time.new - @time < 20)
        sts = @strategies.select { |s| !s.exhausted? }
        sts.each do |s|
          g = s.generate
          unless run.include?(g)
            run << g
            notify_step
            failed = !eval_property(p, g)
            if failed
              @db.insert_error(p, g)
              break
            else
              @db.insert_success(p, g)
            end
          end
        end
      end
      unless failed
        @db.update_property(p)
        notify_success
      end
    else
      notify_failure('No test cases could be generated')
    end
  end
end
