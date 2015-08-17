require "./othello_board.rb"
require "./othello_AI.rb"


ROUND_NUM = 1

## rules
# Players can pass if and only if there isn't any legal moves.

manual_flag = false

ROUND_NUM.times do
    pass_flag = false

    game_board = Board.new(8,8)
    game_board.show(WHT) if ROUND_NUM == 1
    # p_black = RandomAI.new(BLK)   # player_black

    p_black = OpenDegreePlayer.new(BLK)

    if ARGV[0] == "manual" then
      manual_flag = true
      p_white = AI.new(WHT)
    else
      p_white = RandomPlayer.new(WHT)  # player_white
    end

    turn = 1
    while game_board.count_squares_of(EM) != 0
      # FIXME: if player has no legal move, it should surrender.
      next_move  = p_black.think(game_board.copy) if turn % 2 == 0
      next_color = p_black.cl                      if turn % 2 == 0
      if turn % 2 == 1 then
        if(!manual_flag) then
          next_move  = p_white.think(game_board.copy)
          next_color = p_white.cl
        else
          while true do
            if game_board.legal_moves_of(WHT) == [] then
              puts "no legal moves..."
              next_move = NO_LEGAL_MOVE
              next_color = WHT
              break
            end
            print "\n "+YELLOW_COLORED+"x"+BLACK_COLORED+"y: ";   xy = STDIN.gets.to_i
            x = (xy / 10).to_i
            y = (xy % 10)
            puts x
            puts y
            if ( 0 > x || x > game_board.x_lim ||
                 0 > y || y > game_board.y_lim )  then
              puts "out of board"
              next
            end
            if game_board.state[x][y] != EM ||
               game_board.captured_squares([x,y],WHT) == [] then
              puts "not empty, or invalid place"
              next
            end
            next_move = [x,y]
            next_color = WHT
            break
          end
        end
      end

      if next_move == NO_LEGAL_MOVE then
        puts "no legal move"
        turn += 1
        if pass_flag then
          puts "No legal moves for both."
          break
        end
        pass_flag = true
        game_board.show( game_board.back(next_color) )if ROUND_NUM == 1

        next
      end
      game_board.place(next_move, next_color)
      game_board.show( game_board.back(next_color) )if ROUND_NUM == 1
      turn += 1
      pass_flag = false
      # sleep 1
      game_board.write_csv
    end
    #####
    #     show game results
    #

    n_black = game_board.count_squares_of p_black.cl
    n_white = game_board.count_squares_of p_white.cl


       if n_white >  n_black then print " Winner is white."; game_board.show
    elsif n_white == n_black then print " draw"            ; game_board.show
     else print " Winner is " + GREEN_COLORED + "black." + BLACK_COLORED ; game_board.show
     end
     print "   BLACK: #{n_black}  WHITE: #{n_white} \n"
     game_board.kifu
end