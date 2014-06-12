require "./othello_game.rb"
require 'minitest/unit'  # test framework
include MiniTest::Assertions

class RandomAI
  def initialize color # called when initializing
    puts "RandomAI initializer is called"
    @cl = color
  end
  def think
    lgl = return_legal_moves_of @cl
    return lgl[ Random.rand(lgl.length) ]
  end
  attr_reader :cl
end

