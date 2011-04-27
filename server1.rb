require 'rubygems'
require 'socket'
include Socket::Constants

class ChatServer

  def initialize
    @reading = Array.new
    @writing = Array.new
    @clients = Hash.new
  end

  def start
    @server_socket = TCPServer.new('localhost', 4242)
    @reading.push(@server_socket)
    run_acceptor
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
          message = Fiber.yield(chat.strip)
        else
          socket.puts("chat: #{message.strip}")
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

  def run_acceptor
    puts "accepting on shared socket (localhost:4242)"
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
            broadcast(message)
          end 
        end
      end
  end
end

if __FILE__ == $0
  server = ChatServer.new
  server.start
end


