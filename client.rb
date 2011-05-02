require "socket"

class Client

  def initialize(host, port)
	  @socket = TCPSocket.open(host, port)
	end

  def send(message)
    @socket.write(message)
	end

	def listen_to_server
	  Thread.new do  
      while line = @socket.gets
			  yield line
			end
		end
	end

  def close
    @socket.close
	end
end

if __FILE__ == $0
  client = Client.new('localhost', 4444)
	client.listen_to_server do |message|
    puts message
	end

	while message = gets
	  client.send(message)
	end

end
