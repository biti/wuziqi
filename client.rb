require "socket"

ip = 'localhost'
port = 2000

socket = TCPSocket.open(ip, port)

while line = socket.gets
  puts line
end

socket.close
