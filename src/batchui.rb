require 'forwardable'
require 'ui_protocol'


class BatchUI
  extend Forwardable
  include UIProtocol

  def_delegators :@output, :print, :puts

  def initialize(output = $stdout)
    @output = output
  end

  private

  def properties(n)
    puts "Checking #{n} properties"
  end

  def next(property)
    puts property.key.to_s
  end

  def step
    print '.'
  end

  def success
    puts 'Success'
  end

  def failure(cause = nil)
    puts 'Failure'
    puts cause if cause
  end
end
