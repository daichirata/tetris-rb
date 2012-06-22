require "starruby"
include StarRuby

class Texture
  def draw_block(x, y, w, h)
    x, y = x * w, y * h
    fill_rect(x, y, w, h, Color.new(255,255,0,255))
    draw_boder(x, y, w, h)
  end

  def draw_boder(x, y, w, h)
    render_line(x, y, x, y + h,  Color.new(0,0,0,255))
    render_line(x, y + h, x + w, y + h,  Color.new(0,0,0,255))
    render_line(x + w, y + h, x + w, y,  Color.new(0,0,0,255))
    render_line(x + w, y, x, y,  Color.new(0,0,0,255))
  end
end

