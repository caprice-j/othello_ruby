require 'minitest/unit'  # test framework
include MiniTest::Assertions

WHT = -1   # WHTite
 EM =  0   # EMpty
BLK =  1   # BLKack
OUT =  2   # OUTt of board
NO_LEGAL_MOVE = [-1,-1]


GREEN_COLORED = "\e[32m"
BLACK_COLORED = "\e[0m"


class Board

  def initialize inner_x=8, inner_y=8
    raise "Board width/height should be even." if inner_x % 2 == 1 || inner_y % 2 == 1

# Board.state is rotated by 90 degrees, for accesing state[x][y] instead of state[y][x]
# ----------------------------------------------------->  y
# |       0    1    2    3    4    5    6    7    8    9
# | 0  [[OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT],
# | 1   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT],
# | 2   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT],
# | 3   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT],
# | 4   [OUT,  EM,  EM,  EM, BLK, WHT,  EM,  EM,  EM, OUT],
# | 5   [OUT,  EM,  EM,  EM, WHT, BLK,  EM,  EM,  EM, OUT],
# | 6   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT],
# | 7   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT],
# | 8   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT],
# | 9   [OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT]]
# |
# V
#
# x
    @state = Array.new(inner_x+2) { |x|
      Array.new(inner_y+2){ |y|
        if (x == 0 || x == inner_x + 1 || y == 0 || y == inner_y + 1 ) then 
          OUT
        elsif (( x   == inner_x/2 && y   == inner_y/2 )  ||
               ( x-1 == inner_x/2 && y-1 == inner_y/2 )) then
          BLK
        elsif (( x-1 == inner_x/2 && y   == inner_y/2 )  ||
               ( x   == inner_x/2 && y-1 == inner_y/2 )) then
          WHT
        else
          EM
        end
      }
    }
    @x_lim = inner_x + 1 # FIXME: only once
    @y_lim = inner_y + 1 # FIXME: only once
    @history = []
  end

  def copy
    copied = Board.new(@x_lim-1, @y_lim-1)
    @y_lim.times do | y |
      @x_lim.times do | x |
        copied.state[x][y] = state[x][y]
      end
    end
    return copied
  end

  def show
    puts     # equal to '\n'
    print "  "
    (@x_lim-1).times{|i| print " #{i+1}"}
    puts
    @y_lim.times do | y |
      @x_lim.times do | x |
        if x==0 && y != 0 then print "#{y}  " end
        case state[x][y]
        when BLK then  print GREEN_COLORED + "B " + BLACK_COLORED
        when WHT then  print "W "
        when  EM then  print "- "
        end
      end
      puts
    end
    puts
    print "  "
    (@x_lim-1).times{|i| print " #{i+1}"}
    puts
  end

  def count_squares_of color
    n = 0
    state.each{ | column |
      column.each{ | sq |
        n += 1 if sq == color
      }
    }
    return n
  end

  def place xy, color
    x = xy[0]
    y = xy[1]
    assert_equal state[x][y], EM

    sqs = captured_squares([x, y], color)
    history.push([[x,y], sqs])
    state[x][y] = color
    # print "sqs", sqs
    flip sqs
  end

  def redo
    xy, flipped = history.pop
    state[ xy[0] ][ xy[1] ] = EM
    flipped.each do |sq|
     state[ sq[0] ][ sq[1] ] = oppositeColor( state[ sq[0] ][ sq[1] ] )
   end
  end

  def flip sqs
    x = sqs[0][0]
    y = sqs[0][1]
    col = oppositeColor( state[x][y] )
    sqs.each do |sq|
      state[ sq[0] ][ sq[1] ] = col
    end
  end

  def oppositeColor col
    return col == BLK ? WHT : BLK
  end

  def captured_squares startSq, myColor
    assert_equal state[ startSq[0] ][ startSq[1] ], EM
    enemyColor = oppositeColor(myColor)

    directions = [[-1,-1],[ 0,-1],[ 1,-1],
                  [-1, 0]        ,[ 1, 0],
                  [-1, 1],[ 0, 1],[ 1, 1] ]
    stack = []
    directions.each do |xy|
      n_push = 0
      x = startSq[0]
      y = startSq[1]
      # print "startSq #{startSq}\n"
      while true do
        if state[ x - xy[0] ][ y - xy[1] ] != enemyColor then
          if state[ x - xy[0] ][ y - xy[1] ] == EM || 
             state[ x - xy[0] ][ y - xy[1] ] == OUT then
            n_push.times do
              stack.pop
            end
          end
          break
        end
        stack.push( [ x - xy[0], y - xy[1] ] )
        n_push += 1
        x += - xy[0]
        y += - xy[1]
      end
    end
    return stack
  end

  def legal_moves_of col
    stack = []
    @x_lim.times do |x|   # FIXME: start from 0
      @y_lim.times do |y| # FIXME: start from 0
        next if state[x][y] != EM
        if captured_squares([x,y], col) != [] then
          stack.push([x,y])
        end
      end
    end
    return stack
  end

  attr_accessor :x_lim, :y_lim, :state, :history

end
