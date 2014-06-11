require "./othello_game.rb"


$brd = # overwrite
[
   [OU, OU, OU, OU, OU, OU, OU, OU, OU, OU],
   [OU, EM, EM, EM, EM, EM, EM, EM, EM, OU],
   [OU, EM, EM, EM, EM, EM, EM, EM, EM, OU],
   [OU, WH, BL, BL, BL, BL, BL, BL, BL, OU],
   [OU, WH, BL, BL, BL, WH, BL, BL, BL, OU],
   [OU, WH, BL, EM, WH, BL, BL, BL, BL, OU],
   [OU, WH, BL, BL, BL, BL, BL, BL, BL, OU],
   [OU, WH, BL, BL, BL, BL, BL, BL, BL, OU],
   [OU, EM, EM, EM, EM, EM, EM, EM, EM, OU],
   [OU, OU, OU, OU, OU, OU, OU, OU, OU, OU]
]


show
place [3,5], WH
show