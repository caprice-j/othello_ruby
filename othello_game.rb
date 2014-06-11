require 'minitest/unit'  # test framework
include MiniTest::Assertions

WH = -1   # WHite
EM =  0   # EMpty
BL =  1   # BLack
OU =  2   # OUt of board

$brd =
[
   [OU, OU, OU, OU, OU, OU, OU, OU, OU, OU],
   [OU, EM, EM, EM, EM, EM, EM, EM, EM, OU],
   [OU, EM, EM, EM, EM, EM, EM, EM, EM, OU],
   [OU, EM, EM, EM, EM, EM, EM, EM, EM, OU],
   [OU, EM, EM, EM, BL, WH, EM, EM, EM, OU],
   [OU, EM, EM, EM, WH, BL, EM, EM, EM, OU],
   [OU, EM, EM, EM, EM, EM, EM, EM, EM, OU],
   [OU, EM, EM, EM, EM, EM, EM, EM, EM, OU],
   [OU, EM, EM, EM, EM, EM, EM, EM, EM, OU],
   [OU, OU, OU, OU, OU, OU, OU, OU, OU, OU]
]


$brd_width  = $brd[0].length - 2
$brd_height = $brd.length    - 2

def show
  puts     # equal to '\n'
  print " "
  $brd_width.times{|i| print " #{i+1}"}
  puts
  puts
  $brd.each_with_index do | column, idx |
    if idx != 0 && idx <= $brd_height
    then print "#{idx} "
    else next end
    column.each do |square|
      case square
      when BL then  print "X "
      when WH then  print "O "
      when EM then  print "- "
      else
      end
    end
    puts
  end
  puts
  print " "
  $brd_width.times{|i| print " #{i+1}"}
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
  assert_equal $brd[y][x], EM
  $brd[y][x] = color

  sqs = captured_squares [x, y],oppositeColor(color)

  flip sqs
end

def flip sqs
  x = sqs[0][1]
  y = sqs[0][0]
  col = oppositeColor( $brd[y][x] )
  sqs.each do |sq|
    $brd[ sq[0] ][ sq[1] ] = col
  end
end

def oppositeColor col
  return col == BL ? WH : BL
end

def captured_squares startSq, enemyColor
  directions = [[-1,-1],[ 0,-1],[ 1,-1],
                [-1, 0]        ,[ 1, 0],
                [-1, 1],[ 0, 1],[ 1, 1] ]
  stack = []
  directions.each do |xy|
    n_push = 0
    x = startSq[0]
    y = startSq[1]
    while true do
      if $brd[ y - xy[1] ][ x - xy[0] ] != enemyColor then
        if $brd[ y - xy[1] ][ x - xy[0] ] == EM  then
          n_push.times do
            stack.pop
          end
        end
        break
      end
      stack.push( [ y - xy[1], x - xy[0] ] )
      n_push += 1
      x += - xy[0]
      y += - xy[1]
    end
  end
  return stack
end

