require 'minitest/unit'  # test framework
include MiniTest::Assertions

WHT = -1   # WHTite
 EM =  0   # EMpty
BLK =  1   # BLKack
OUT =  2   # OUTt of board

# rotate 90 degrees    ------------------------------------->  y
$brd =
[ #  0    1    2    3    4    5    6    7    8    9
   [OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT], # 0
   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT], # 1
   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT], # 2
   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT], # 3
   [OUT,  EM,  EM,  EM,  EM, WHT,  EM,  EM,  EM, OUT], # 4
   [OUT,  EM,  EM,  EM, WHT, BLK,  EM,  EM,  EM, OUT], # 5
   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT], # 6
   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT], # 7
   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT], # 8
   [OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT]  # 9
]
# |
# |
# V  x

##  x,y = 1,1   2,1  3,1  

$brd_y_lim = $brd[0].length - 1
$brd_x_lim = $brd.length    - 1

GREEN_COLORED = "\e[32m"
BLACK_COLORED = "\e[0m"

def show
  puts     # equal to '\n'
  print "  "
  ($brd_x_lim-1).times{|i| print " #{i+1}"}
  puts
  $brd_y_lim.times do | y |
    $brd_x_lim.times do | x |
      if x==0 && y != 0 then print "#{y}  " end
      case $brd[x][y]
      when BLK then  print GREEN_COLORED + "B " + BLACK_COLORED
      when WHT then  print "W "
      when  EM then  print "- "
      end
    end
    puts
  end
  puts
  print "  "
  ($brd_x_lim-1).times{|i| print " #{i+1}"}
  puts
end

def count_disk_of color
  n = 0
  $brd.each{ | column |
    column.each{ | sq |
      n += 1 if sq == color
    }
  }
  return n
end

def place startSq, color
  x = startSq[0]
  y = startSq[1]
  assert_equal $brd[x][y], EM

  sqs = captured_squares [x, y],oppositeColor(color)
  $brd[x][y] = color
  print "sqs", sqs
  flip sqs
end

def flip sqs
  x = sqs[0][0]
  y = sqs[0][1]
  col = oppositeColor( $brd[x][y] )
  sqs.each do |sq|
    $brd[ sq[0] ][ sq[1] ] = col
  end
end

def oppositeColor col
  return col == BLK ? WHT : BLK
end

def captured_squares startSq, enemyColor
  assert_equal $brd[ startSq[0] ][ startSq[1] ], EM

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
      if $brd[ x - xy[0] ][ y - xy[1] ] != enemyColor then
        if $brd[ x - xy[0] ][ y - xy[1] ] == EM || 
           $brd[ x - xy[0] ][ y - xy[1] ] == OUT then
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

def return_legal_moves_of col
  stack = []
  $brd_x_lim.times do |x|   # FIXME: start from 0
    $brd_y_lim.times do |y| # FIXME: start from 0
      next if $brd[x][y] != EM
      if captured_squares([x,y], oppositeColor(col)) != [] then
        stack.push([x,y])
      end
    end
  end
  return stack
end





