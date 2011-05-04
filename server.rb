# encoding: utf-8

require 'socket'
include Socket::Constants

require './eye'

class WuziqiServer
  
	attr_reader :clients, :eyes, :role

  def initialize(port)
    @reading = Array.new
    @writing = Array.new
    @clients = Hash.new

    @server_socket = TCPServer.new('localhost', port)
    @reading.push(@server_socket)

	  @role = {}
	  @eyes = []
	  @row_number	= 20
	end

	def eyes_string
	  @eyes.map{|e| "#{e.role}:#{e.x},#{e.y}"}.join('|')
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

					yield self, socket, message

          m = eyes_string

          # 判断是否赢了
      	  [1, 2].each do |sym|
            if win?(sym)
			        puts "client: %s  win!!!!!!!" % sym
							m = "Win:#{sym}"
			      end
		      end

          broadcast(m)
        end 
      end
    end
  end

  def broadcast(message)
    @clients.each_pair do |key, value|
      puts "broadcast to client #{key} message: #{message}"
      value.resume( message )
    end
  end

  def add_client

    socket = @server_socket.accept_nonblock
    @reading.push(socket)

    # 为客户端分配代表符号
		@role[socket] = @clients.size % 2 == 0 ? 'x' : '@'
    socket.puts("Role:%s" % @role[socket])

    @clients[socket] = Fiber.new do |message|
      loop {
        if message.nil?
          chat = socket.gets
          socket.flush
          message = Fiber.yield(chat)
        else
          socket.puts( message )
          socket.flush
          message = Fiber.yield
        end
      }
    end

		#@eyes[socket] = []

    puts "client %s connected" % socket
    return @clients[socket]
  end

  # 思路：寻找有没有连续的5个棋子。20个行，20个列，还有斜行24个，共找64次
	def win?(client_symbol)
	  puts "sym: %s" % client_symbol.inspect
	  puts "eyes: %s" % @eyes.inspect
	  return false if @eyes.size == 0

		result = false

	  # 行
   	(1..20).each do |i|
		  count = 0
		  (1..20).each do |j|
			  eye = @eyes.find{|e| e.x == i and e.y == j and e.role == client_symbol}
				if eye 
				  count += 1
				else
				  count = 0
				end

			  if count >= 5
				  result = true
			  end
			end
		end
		   
	  # 列
  	(1..20).each do |j|
		  count = 0
		  (1..20).each do |i|
			  eye = @eyes.find{|e| e.x == i and e.y == j and e.role == client_symbol}
				if eye 
				  count += 1
				else
				  count = 0
				end

			  if count >= 5
				  result = true
			  end
			end
		end
		
		(5..20).each do |j|
		  i = 1 
		  count = 0
		  while true 
			  begin
  		  	eye = @eyes.find{|e| e.x == i and e.y == j and e.role == client_symbol}
  				if eye 
  				  count += 1
  				else
  				  count = 0
  				end

  			  if count >= 5
					  result = true
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
  		  	eye = @eyes.find{|e| e.x == i and e.y == j and e.role == client_symbol}
  				if eye
  				  count += 1
  				else
  				  count = 0
  				end

  			  if count >= 5
					  result = true
  			  end
				end

			  if j >= @row_number
				  break
				end

  			i -= 1
  			j += 1
			end
		end

    return result
	end
end

if __FILE__ == $0
  WuziqiServer.new(4444).run_acceptor do |server, socket, message|
	 

    arr = message.split(',')
		eye = Eye.new(arr[0].to_i, arr[1].to_i, server.role[socket])
	  #server.eyes[socket] << eye

    unless server.eyes.find{|e| e.x == eye.x and e.y == eye.y}
	    server.eyes << eye
		end

	end
end

