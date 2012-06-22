# -*- coding: utf-8 -*-
require "./starruby_ext"

module Tetris
  ROWS = 20
  COLS = 10

  class View
    WIDTH = 300
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
          if @model.bord[col][row] == 1
            screen.draw_block(row, col, BLOCK_W, BLOCK_H)
          end
        end
      end

      @model.current.each do |col, rows|
        rows.each do |row, val|
          if @model.current[col][row] == 1
            screen.draw_block(row, col, BLOCK_W, BLOCK_H)
          end
        end
      end
    end
  end

  class Model
    attr_reader :bord, :current

    SHAPES = [
      [ 1,1,1,1 ], # ■■■■

      [ 1,1,1,0,   # ■■■
        1 ],       # ■

      [ 1,1,1,0,   # ■■■
        0,0,1 ],   #   ■

      [ 1,1,0,0,   # ■■
        1,1 ],     # ■■

      [ 1,1,0,0,   # ■■
        0,1,1 ],   #   ■■

      [ 0,1,1,0,   #   ■■
        1,1 ],     # ■■

      [ 0,1,0,0,   #   ■
        1,1,1 ]    # ■■■
    ]

    def initialize
      create_bord
      new_shape
    end

    def create_bord
      @bord = Hash.new {|k,v| k[v] = {}}
      (0..(ROWS - 1)).each do |y|
        (0..(COLS - 1)).each {|x| @bord[y][x] = 0}
      end
    end

    def new_shape
      shape = SHAPES.sample
      @current = Hash.new {|k,v| k[v] = {}}
      (0..3).each do |y|
        (0..3).each do |x|
          i = 4 * y + x
          @current[y][x] = shape[i] ? shape[i] : 0
        end
      end
    end
  end
end

model = Tetris::Model.new
view = Tetris::View.new(model)

StarRuby::Game.run(*Tetris::View.size, :fps => 1) do |game|
  view.render(game.screen)
  model.new_shape
end
