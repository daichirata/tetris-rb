require "starruby"
include StarRuby

class Texture
  def draw_block(x, y, w, h, color_num)
    x, y = x * w, y * h
    fill_rect(x, y, w, h, Color.select(color_num))
    draw_boder(x, y, w, h)
  end

  def draw_boder(x, y, w, h)
    render_line(x, y, x, y + h, Color.new(0,0,0,255))
    render_line(x, y + h, x + w, y + h, Color.new(0,0,0,255))
    render_line(x + w, y + h, x + w, y, Color.new(0,0,0,255))
    render_line(x + w, y, x, y, Color.new(0,0,0,255))
  end
end

class Color
  COLORS = [
    [255,0,0],[0,255,0],[0,0,255],[255,0,255],[255,255,0],[0,255,255],[255,255,255]
  ]

  def self.select num
    Color.new(*COLORS[num -1], 255)
  end
end
