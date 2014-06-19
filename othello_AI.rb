require "./othello_board.rb"
require 'minitest/unit'  # test framework
include MiniTest::Assertions

class AI
  def initialize color # called when initializing
    # puts "initializer is called"
    @cl = color
  end
  attr_reader :cl
end

class RandomPlayer < AI

  def think copied_board
    lgl = copied_board.legal_moves_of @cl
    return NO_LEGAL_MOVE if lgl == []
    return lgl[ Random.rand(lgl.length) ]
  end
  attr_reader :cl

end

class MinimaxPlayer < AI
  def think copied_board
    # best_move =
    minimax(copied_board, @cl, 0)
  end

  def edge_weighted_counting brd, myCol
    val = 0
    mul = 1
    xl = brd.x_lim
    yl = brd.y_lim
    edges = [[1,1],[1,yl-1],[xl-1,1],[xl-1,yl-1]]
    yl.times do | y |
      xl.times do | x |
        # if( brd.state[x][y] == @cl ) then

        #   # if (x == 1 || x == xl-1 ||
        #   #     y == 1 || y == yl-1 ) then
        #   #   val += 5
        #   # else val += 1
        #   # end
        #   # val += ((x-3)^4).abs + ((y-3)^4).abs

        # end
        # if(edges.index([x,y])!=nil) then
        #   val += brd.state[x][y] == @cl ? 100 : -1000 if brd.state[x][y] != EM
        # end
        # val -= (brd.legal_moves_of(brd.back(@cl))).length * 20


      end
    end
    return val
  end

  def evaluate brd
    val = 0
    val += edge_weighted_counting(brd, @cl)
    # just numbers of my squares
    return val
  end

  def minimax brd, now_player, depth
    if depth >= 3 then
      return evaluate brd
    end
    lgl = brd.legal_moves_of(now_player)
    # print "\nlegal #{lgl} \n"
    values = []
    if lgl == [] then
      return NO_LEGAL_MOVE if depth == 0
      # pass next arguments
      values.push( minimax( brd, brd.back(now_player), depth+1 ) )
      # history redo
    else

      lgl.each do |mv| # all search

        brd.place mv, now_player
        # brd.show
        values.push( minimax( brd, brd.back(now_player), depth+1 ) )
        brd.redo
      end
    end
      # print "DEPTH: #{depth} values: #{values}\n"
    if depth != 0 then
      return depth % 2 == 0 ? values.max : values.min
    end


    best_move = lgl[ lgl.index(lgl.max) ]
    return best_move
  end
  attr_reader :cl
end

class OpenDegreePlayer < AI
  def think copied_board
    # best_move =
    minimax(copied_board, @cl, 0, 0)
  end

  def evaluate brd, od
    xl = brd.x_lim
    yl = brd.y_lim
    edges = [[1,1],[1,yl-1],[xl-1,1],[xl-1,yl-1]]
    debt = 0
    debt += od
    yl.times do | y |
      xl.times do | x |
        if(edges.index([x,y])!=nil) then
          debt += brd.state[x][y] == @cl ? -100000 : 100000 if brd.state[x][y] != EM
        end
      end
    end
    return debt
  end

  def minimax brd, now_player, depth, od
    if depth >= 5 then
      return evaluate brd,od
      # return od
    end
    lgl = brd.legal_moves_of(now_player)
    # print "\nlegal #{lgl} \n"
    degrees = []
    if lgl == [] then
      return NO_LEGAL_MOVE if depth == 0
      # pass next arguments
      degrees.push( minimax( brd, brd.back(now_player), depth+1, od ) )
      # history redo
    else
      lgl.each do |mv| # all search
        kh = brd.kaihodo(mv, @cl)

        brd.place mv, now_player
        # brd.show
        if now_player == @cl then
          degrees.push( minimax( brd, brd.back(now_player), depth+1, od + kh ) )
        else
          degrees.push( minimax( brd, brd.back(now_player), depth+1, od - kh ) )
        end
        brd.redo
      end
    end
      # print "DEPTH: #{depth} degrees: #{degrees}\n"
    if depth != 0 then
      return depth % 2 == 0 ? degrees.min : degrees.max
    end

    best_move = lgl[ degrees.index(degrees.min) ]
    # best_move = lgl[ lgl.index(lgl.max) ]
    return best_move
  end
  attr_reader :cl

end

