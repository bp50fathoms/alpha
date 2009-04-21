class Strategy
  def initialize
    @property = nil
  end

  def set_runner(runner)
    @runner = runner
  end

  def set_property(property)
    @property = property
    @count = 0
    set(property)
  end

  def generate
    if @property and !exhausted?
      g = gen
      @count += 1
      g
    else
      error
    end
  end

  def exhausted?
    @property ? (!can or exh) : error
  end

  def progress
    @property ? (can ? pro : 0) : error
  end

  private

  def error
    raise 'Wrong state'
  end

  def set(property); end
end
