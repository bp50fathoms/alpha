require 'observer'
require 'pipeline'
require 'pdecorator'
require 'plist'
require 'property'
require 'ui'


class Runner
  include Filter, Observable

  def process(i)
    add_observer(UI.new(self)) if count_observers == 0
    to_check = i.select { |p| !p.falsified? }
    notify_properties(to_check)
    check(to_check)
  end

  private

  def notify_properties(properties)
    changed
    notify_observers(:properties, properties.size)
  end

  def notify_next(property)
    changed
    notify_observers(:next, property)
  end

  def notify_step
    changed
    notify_observers(:step)
  end

  def notify_success
    changed
    notify_observers(:success)
  end

  def notify_failure(cause = nil)
    changed
    notify_observers(:failure, cause)
  end
end


class SequentialRunner < Runner
  private

  def check(properties)
    properties.each do |p|
      notify_next(p)
      unless p.arity == 0
        check_property(p)
      else
        notify_success if eval_property(p, [])
      end
    end
  end

  def eval_property(p, args)
    begin
      a = (args.length > 0 ? args + [rc = ResultCollector.new] : args)
      r = p.call(*a)
      if r
        p.cover_table.add_result(rc) if rc
      else
        failure(p, args)
      end
      r
    rescue Exception => e
      failure(p, args, e)
      false
    end
  end

  def failure(p, args, exception = nil)
    p.falsifying_case = args
    message = ''
    message += "Input #{args.inspect}" if !args.empty?
    if exception
      message += "\n" if !message.empty?
      message += "Unhandled #{exception}"
    end
    notify_failure(message.empty? ? nil : message)
  end
end
