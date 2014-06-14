require "./othello_board.rb"
require "./othello_AI.rb"


ROUND_NUM = 10

## rules
# Players can pass if and only if there isn't any legal moves.

ROUND_NUM.times do
    pass_flag = false

    game_board = Board.new(6,6)
    game_board.show if ROUND_NUM == 1
    # p_black = RandomAI.new(BLK)   # player_black
    p_black = OpenDegreePlayer.new(BLK)
    p_white = RandomPlayer.new(WHT)  # player_white

    turn = 1
    while game_board.count_squares_of(EM) != 0
      # FIXME: if player has no legal move, it should surrender.
      next_move  = p_black.think(game_board.copy) if turn % 2 == 0
      next_color = p_black.cl                      if turn % 2 == 0
      next_move  = p_white.think(game_board.copy) if turn % 2 == 1
      next_color = p_white.cl                      if turn % 2 == 1
      if next_move == NO_LEGAL_MOVE then
        puts "no legal move"
        turn += 1
        if pass_flag then
          puts "No moves."
          break
        end
        pass_flag = true
        next
      end
      game_board.place(next_move, next_color)
      game_board.show if ROUND_NUM == 1
      turn += 1
      pass_flag = false
      # sleep 1
    end
    #####
    #     show game results
    #

    n_black = game_board.count_squares_of p_black.cl
    n_white = game_board.count_squares_of p_white.cl


       if n_white >  n_black then print "Winner is white."; game_board.show
    elsif n_white == n_black then print "draw"            ; game_board.show
     else print "Winner is " + GREEN_COLORED + "black." + BLACK_COLORED ; game_board.show
     end
     print "  # BLACK: #{n_black}  WHITE: #{n_white} \n"
end