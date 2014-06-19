require 'minitest/unit'  # test framework
include MiniTest::Assertions
require 'csv'

WHT = -1   # WHTite
 EM =  0   # EMpty
BLK =  1   # BLKack
OUT =  2   # OUTt of board
NO_LEGAL_MOVE = [-1,-1]


UNDERLINE = "\x1b[4m"
BLACK_BACKGROUND  = "\e[0m"
  BLUE_COLORED = "\e[34m"
GREEN_COLORED  = "\e[32m"
YELLOW_COLORED = "\e[33m"
BLACK_COLORED  = "\e[0m"
DIRECTIONS =  [[-1,-1],[ 0,-1],[ 1,-1],
               [-1, 0]        ,[ 1, 0],
               [-1, 1],[ 0, 1],[ 1, 1] ]

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

  def show color=EM
    puts     # equal to '\n'
    print "  " + YELLOW_COLORED
    (@x_lim-1).times{|i| print " #{i+1}"}
    print BLACK_COLORED + ""
    @y_lim.times do | y |
      @x_lim.times do | x |
        if x==0 && y != 0 then print "#{y}  " end
        if @history.last != nil && (@history.last)[0] == [x,y] then
          print UNDERLINE
        end
        case state[x][y]
        when BLK then  print GREEN_COLORED + "B " + BLACK_COLORED
        when WHT then  print "W "
        when  EM then
          if captured_squares([x,y], color) == [] then
            print ". "
          else
            print BLUE_COLORED + "% " + BLACK_COLORED
          end
        end
        print BLACK_BACKGROUND
      end
      puts
    end
    print "  " + YELLOW_COLORED
    (@x_lim-1).times{|i| print " #{i+1}"}
    print BLACK_COLORED + ""
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

  def kaihodo xy, color
    x = xy[0]
    y = xy[1]
    assert_equal state[x][y], EM

    sqs = captured_squares([x, y], color)
    return kaihodo_inner(sqs)
  end

  def kaihodo_inner sqs
    val = 0
    sqs.each{ |sq|
      x = sq[0]
      y = sq[1]
      DIRECTIONS.each{ |xy|
        if state[ x - xy[0] ][ y-xy[1] ] == EM then
          val += 1
        end
      }
    }
    return val
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
     state[ sq[0] ][ sq[1] ] = back( state[ sq[0] ][ sq[1] ] )
   end
  end

  def flip sqs
    x = sqs[0][0]
    y = sqs[0][1]
    col = back( state[x][y] )
    sqs.each do |sq|
      state[ sq[0] ][ sq[1] ] = col
    end
  end

  def oppositeColor col
    return col == BLK ? WHT : BLK
  end

  def back col
    return oppositeColor(col)
  end

  def captured_squares startSq, myColor
    assert_equal state[ startSq[0] ][ startSq[1] ], EM
    enemyColor = back(myColor)

    stack = []
    DIRECTIONS.each do |xy|
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

  def kifu

    inner_x = @x_lim - 1
    inner_y = @y_lim - 1

    move_number = Array.new(inner_x+2) { |x|
      Array.new(inner_y+2){ |y|
        if (x == 0 || x == inner_x + 1 || y == 0 || y == inner_y + 1 ) then
          OUT
        else
          EM
        end
      }
    }
    n = (x_lim-1)*(y_lim-1)-4
    while xy = history.pop
      x = xy[0][0]
      y = xy[0][1]
      move_number[x][y] = n
      n -= 1
    end

    f = open("kifu.txt", "a")
    tm = Time.now
    f.write("\nBLACK #{count_squares_of BLK}  WHITE #{count_squares_of WHT}  ")
    f.write("#{tm.year}#{sprintf("%02d",tm.month)}#{sprintf("%02d",tm.day)}")
    f.write(" #{sprintf("%02d",tm.hour)}:#{sprintf("%02d",tm.min)}")
    print "  " + YELLOW_COLORED
    (@x_lim-1).times{|i|
      print "  #{i+1} "
    }
    print BLACK_COLORED + ""


    @y_lim.times do | y |
      @x_lim.times do | x |
        if x==0 && y != 0 then 
          print "#{y}  " 
        end
        if move_number[x][y] == OUT then
        else
          print GREEN_COLORED if move_number[x][y] % 2  == 0
          print sprintf("%3d ", move_number[x][y].to_s)
          f.write("#{sprintf("%3d ", move_number[x][y].to_s)}")
          print BLACK_BACKGROUND
        end
      end
      # f.write("  #{y}") if move_number[x][y] != OUT
      f.write("\n")
      puts
    end
    print "  " + YELLOW_COLORED
    (@x_lim-1).times{|i| print "  #{i+1} "}
    print BLACK_COLORED + ""

  end

  def write_csv
    file_name = "./state.csv"
    CSV.open(file_name, "w") do |csv_next_line|
      @y_lim.times do | y |
        stack = []
        @x_lim.times do | x |
          stack.push(@state[x][y].to_s)
        end
        csv_next_line << stack
      end
    end
    `cp ./state.csv ./state_for_read.csv`
  end

  attr_accessor :x_lim, :y_lim, :state, :history

end
