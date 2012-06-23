require "./starruby_ext"

module Tetris
  ROWS = 20
  COLS = 10

  class View
    WIDTH  = 300
    HEIGHT = 600
    BLOCK_W = WIDTH / COLS
    BLOCK_H = HEIGHT / ROWS

    def self.size
      [WIDTH, HEIGHT]
    end

    def initialize(model)
      @model = model
    end

    def render(screen)
      screen.clear
      @model.bord.each do |col, rows|
        rows.each do |row, val|
          if @model.bord[col][row] != 0
            screen.draw_block(row, col, BLOCK_W, BLOCK_H, val)
          end
        end
      end

      @model.current.each do |col, rows|
        rows.each do |row, val|
          if @model.current[col][row] != 0
            screen.draw_block(row + @model.currentX, col + @model.currentY, BLOCK_W, BLOCK_H, val)
          end
        end
      end
    end
  end

  class Model
    attr_reader :bord, :current, :currentX, :currentY

    SHAPES = [
      { 0 => { 0 => 1, 1 => 1, 2 => 1, 3 => 1 } },
      { 0 => { 0 => 1, 1 => 1, 2 => 1, 3 => 0 },
        1 => { 0 => 1, 1 => 0, 2 => 0, 3 => 0 } },
      { 0 => { 0 => 1, 1 => 1, 2 => 1, 3 => 0 },
        1 => { 0 => 0, 1 => 0, 2 => 1, 3 => 0 } },
      { 0 => { 0 => 1, 1 => 1, 2 => 0, 3 => 0 },
        1 => { 0 => 1, 1 => 1, 2 => 0, 3 => 0 } },
      { 0 => { 0 => 1, 1 => 1, 2 => 0, 3 => 0 },
        1 => { 0 => 0, 1 => 1, 2 => 1, 3 => 0 } },
      { 0 => { 0 => 0, 1 => 1, 2 => 1, 3 => 0 },
        1 => { 0 => 1, 1 => 1, 2 => 0, 3 => 0 } },
      { 0 => { 0 => 0, 1 => 1, 2 => 0, 3 => 0 },
        1 => { 0 => 1, 1 => 1, 2 => 1, 3 => 0 } },
    ]

    def initialize
      create_bord
      new_shape
    end

    def current_enum(&block)
      (0..3).each{|y| (0..3).each{|x| block.call(y, x)}}
    end

    def create_bord
      @bord = Hash.new {|k,v| k[v] = {}}
      (0..(ROWS - 1)).each do |y|
        (0..(COLS - 1)).each {|x| @bord[y][x] = 0}
      end
    end

    def new_shape
      shape = SHAPES.sample
      id = (1..SHAPES.size).to_a.sample

      @current = Hash.new {|k,v| k[v] = {}}
      current_enum do |y, x|
        @current[y][x] = shape[y] ? shape[y][x] == 1 ? id : 0 : 0
      end
      @currentX, @currentY = 5, 0
    end

    def tick
      if valid
        @currentY += 1
      else
        freez
        clear_lines
        new_shape
      end
    end

    def freez
      current_enum do |y, x|
        @bord[y + @currentY][x + @currentX] = @current[y][x] if @current[y][x] != 0
      end
      @bord.delete(20)
    end

    def clear_lines
      @bord.each do |y, rows|
        unless rows.values.include?(0)
          rows.each {|x, val| @bord[y][x] = 0}
          y.downto(1).each do |i|
            @bord[i] = @bord[i - 1]
          end
        end
      end
    end

    def valid(current = nil, move_value = nil)
      line = if move_value
        ->(x,y) {@bord[y + @currentY][x + @currentX + move_value]}
      else
        ->(x,y) {@bord[y + @currentY + 1][x + @currentX]}
      end

      (current ||= @current).map do |y, rows|
        rows.each {|x, val| return false if val != 0 && line[x, y] != 0}
      end
    end

    def move_right
      @currentX += 1 if valid(nil, 1)
    end

    def move_left
      @currentX -= 1 if valid(nil, -1)
    end

    def rotate
      @_current = Hash.new {|k,v| k[v] = {}}
      current_enum do |y, x|
        @_current[y][x] = @current[3 - x][y]
      end

      @current = @_current if valid(@_current)
    end
  end

  class Controller
    def update(model)
      if Input.keys(:keyboard).include?(:right)
        model.move_right
      end

      if Input.keys(:keyboard).include?(:left)
        model.move_left
      end

      if Input.keys(:keyboard).include?(:up)
        model.rotate
      end

      exit 0 if Input.keys(:keyboard).include?(:escape)
    end
  end
end

model = Tetris::Model.new
view  = Tetris::View.new(model)
controller = Tetris::Controller.new

StarRuby::Game.run(*Tetris::View.size, :fps => 5) do |game|
  view.render(game.screen)
  controller.update(model)
  model.tick
end
