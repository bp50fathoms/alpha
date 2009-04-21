require 'curses'
require 'lineutils'
require 'thread'


class ScrollPane
  include Curses, LineUtils

  def initialize
    @buffer = []
    @top = 0
    init_screen
    cbreak
    nonl
    noecho
    @screen = stdscr
    @screen.scrollok(true)
    @screen.keypad(true)
  end

  def set_lines(index, lines)
    Thread.exclusive do
      i = 0
      mlen = @screen.maxx - 1
      lines.each_line do |line|
        r = line
        while !r.empty? do
          l, r = divide(r, mlen)
          @buffer[index + i] = full_wide(l, mlen)
          i += 1
        end
      end
      repaint
      i
    end
  end

  def scroll_up
    Thread.exclusive do
      if @top > 0
        @top -= 1
        repaint
        true
      else
        false
      end
    end
  end

  def scroll_down
    Thread.exclusive do
      if @top + @screen.maxy < @buffer.size
        @top += 1
        repaint
        true
      else
        false
      end
    end
  end

  def close
    Thread.exclusive do
      @screen.close
      close_screen
      @buffer.each { |e| puts e || ' ' }
    end
  end

  private

  def repaint
    (0..@screen.maxy - 1).each do |e|
      @screen.setpos(e, 0)
      @screen.addstr(@buffer[@top + e] || blank_line)
    end
    @screen.refresh
  end

  def blank_line
    ' ' * (@screen.maxx - 1)
  end
end
