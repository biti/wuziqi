require 'rubygems'
require 'socket'
include Socket::Constants

class ChatServer

  def initialize(port)
    @reading = Array.new
    @writing = Array.new
    @clients = Hash.new

    @server_socket = TCPServer.new('localhost', port)
    @reading.push(@server_socket)
  end

  def run_acceptor
    loop do
      puts "current clients: #{@clients.length}"
      readable, writable = IO.select(@reading, @writing)

      readable.each do |socket|
        if socket == @server_socket
          add_client
        else
          client = @clients[socket]
          message = client.resume
          puts "client #{socket} sent: #{message}"
					yield message
          broadcast(message)
        end 
      end
    end
  end

  private

  def add_client
    socket = @server_socket.accept_nonblock
    @reading.push(socket)

    @clients[socket] = Fiber.new do |message|
      loop {
        if message.nil?
          chat = socket.gets
          socket.flush
          message = Fiber.yield(chat)
        else
          socket.puts(message)
          socket.flush
          message = Fiber.yield
        end
      }
    end
    puts "client #{socket} connected"
    return @clients[socket]
  end

  def broadcast(message)
    @clients.each_pair do |key, value|
      puts "invoking client #{key}"
      value.resume(message)
    end
  end


end

class Wuziqi
  A = :A
	B = :B

  def initialize
	  @eyes = {}
	  @eyes[A] = []
	  @eyes[B] = []
	  @row_number	= 20
	end

  # 思路：寻找有没有连续的5个棋子。20个行，20个列，还有斜行24个，共找64次
	def win?(role)

	  # 行
   	(1..20).each do |i|
		  count = 0
		  (1..20).each do |j|
			  eye = @eyes[role].find{|e| e.x == i and e.y == j}
				if eye and eye.used?(role)
				  count += 1
				else
				  count = 0
				end

			  if count >= 5
				  win_exit!
			  end
			end
		end
		   
	  # 列
  	(1..20).each do |j|
		  count = 0
		  (1..20).each do |i|
			  eye = @eyes[role].find{|e| e.x == i and e.y == j}
				if eye and eye.used?(role)
				  count += 1
				else
				  count = 0
				end

			  if count >= 5
				  win_exit!
			  end
			end
		end
		
		(5..20).each do |j|
		  i = 1 
		  count = 0
		  while true 
			  begin
  		  	eye = @eyes[role].find{|e| e.x == i and e.y == j}
  				if eye and eye.used?(role)
  				  count += 1
  				else
  				  count = 0
  				end

  			  if count >= 5
  				  win_exit!
  			  end
				end

			  if j == 1
				  break
				end

  			i += 1
  			j -= 1
			end
		end

		@row_number.downto(5).each do |j|
		  i = @row_number 
		  count = 0
		  while true 
			  begin
  		  	eye = @eyes[role].find{|e| e.x == i and e.y == j}
  				if eye and eye.used?(role)
  				  count += 1
  				else
  				  count = 0
  				end

  			  if count >= 5
  				  win_exit!
  			  end
				end

			  if j >= @row_number
				  break
				end

  			i -= 1
  			j += 1
			end
		end

	end

end

if __FILE__ == $0
  wuziqi = Wuziqi.new

  ChatServer.new(4444).run_acceptor do |message|
	  puts "in block. message: %s" % message
	end
end


