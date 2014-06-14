require "./othello_board.rb"
require "./othello_AI.rb"


show_board

p_black = RandomAI.new(BLK)   # player_black
p_white = RandomAI.new(WHT)  # player_white

turn = 1
while count_squares_of(EM) != 0
  # FIXME: if player has no legal move, it should surrender.
  next_move  = p_black.think if turn % 2 == 0
  next_color = p_black.cl    if turn % 2 == 0
  next_move  = p_white.think if turn % 2 == 1
  next_color = p_white.cl    if turn % 2 == 1
  if next_move == NO_LEGAL_MOVE then
    puts "no legal move"
    turn += 1
    next
  end
  place(next_move, next_color)
  show_board
  turn += 1
  # sleep 1
end

#####
#     show game results
#

n_black = count_squares_of p_black.cl
n_white = count_squares_of p_white.cl

puts "# BLACK: {n_black}  WHITE: #{n_white} "

   if n_white >  n_black then puts "Winner is white."
elsif n_white == n_black then puts "draw"
 else                         puts "Winner is black."
 end