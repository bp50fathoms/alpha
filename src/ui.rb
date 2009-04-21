require 'batchui'
require 'textui'


class UI
  def self.new(output = nil)
    if Object.const_defined?(:IRB) or output
      BatchUI.new(output)
    else
      TextUI.new
    end
  end
end
