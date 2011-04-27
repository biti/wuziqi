require "socket"

require "socket"

port = ARGV.size > 0 ? ARGV.shift : 4444
print port, "\n"

s = TCPSocket.open("localhost", port)

while gets
  s.write($_)
  print(s.gets)
end
s.close
