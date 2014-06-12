require "./othello_game.rb"
require "./othello_AI.rb"


$brd = # overwrite
[
   [OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT],
   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT],
   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT],
   [OUT, WHT, BLK, BLK, BLK, BLK, BLK, BLK, BLK, OUT],
   [OUT, WHT, BLK, BLK, BLK, WHT, BLK, BLK, BLK, OUT],
   [OUT, WHT, BLK,  EM, WHT, BLK, BLK, BLK, BLK, OUT],
   [OUT, WHT, BLK, BLK, BLK, BLK, BLK, BLK, BLK, OUT],
   [OUT, WHT, BLK, BLK, BLK, BLK, BLK, BLK, BLK, OUT],
   [OUT,  EM,  EM,  EM,  EM,  EM,  EM,  EM,  EM, OUT],
   [OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT, OUT]
]

# show
# place [5,3], WHT

show
rp = RandomAI.new(WHT)
place(rp.think, rp.cl)
show
