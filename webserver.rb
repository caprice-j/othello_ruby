require 'webrick'

# :DocumentRoot => "./"
server = WEBrick::HTTPServer.new(:Port => 8080)
trap("INT"){s.shutdown}
s.start