require 'curses'
require 'progressbar'
require 'scrollpane'
require 'ui_protocol'


class TextUI
  include Curses, UIProtocol

  private

  def properties(n)
    @progressbar = ProgressBar.new(n)
    @scrollpane = ScrollPane.new
    @failures = 0
    @slash = ' '
    @property = nil
    @errorline = 4
    refresh
    Thread.new { loop }
  end

  def next(property)
    @property = property
    refresh
  end

  def step
    @slash = (@slash == '/' ? '\\' : '/')
    refresh
  end

  def success
    step_p
  end

  def failure(cause = nil)
    @failures += 1
    print_error("\n#{@failures}. #{@property.key} failed\n#{cause}")
    step_p
  end

  def refresh
    @scrollpane.set_lines(0, status)
  end

  def step_p
    @slash = ' '
    @progressbar.step
    refresh
    @scrollpane.close if @progressbar.full?
  end

  def print_error(error = nil)
    @errorline += @scrollpane.set_lines(@errorline, error)
  end

  def status
    @progressbar.to_str + "\n" + case_line + "\n" + fails_line
  end

  def case_line
    if @progressbar.full?
      'Finished'
    elsif @property.nil?
      ''
    else
      @slash + ' checking ' + @property.key.to_s
    end
  end

  def fails_line
    "#{@failures} failure(s)\n"
  end

  def loop
    while true do
      c = getch
      Thread.exclusive do
        case c
        when KEY_UP, KEY_CTRL_P
          r = @scrollpane.scroll_up
        when KEY_DOWN, KEY_CTRL_N
          r = @scrollpane.scroll_down
        end
        beep if !r
      end
    end
  end
end
