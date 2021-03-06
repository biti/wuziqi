# encoding: utf-8

require './client'
require './eye'

class Canvas

  attr_accessor :role, :eyes

	GEZI = '.'
	
	def initialize
	  # 全部棋子
	  @eyes = [] 
		@row_number = 20
	end

	def draw
		(0..20).each do |i|
		  if i == 0
		    print "   "
			else
		    print "%2d " % i
			end
		  (1..20).each do |j|
			  if i == 0
				  print "%2d " % j
					next
				end
			  print " %s " % GEZI  
			end
			puts
		end
	end

	def redraw

		(0..20).each do |i|
		  if i == 0
		    print "   "
			else
		    print "%2d " % i
			end
		  (1..20).each do |j|
			  if i == 0
					print "%2d " % j
					next
				end

			  # 绘制已经下的棋子
			  if eye = @eyes.find{|e| e.x == i and e.y == j}
				  print " #{eye.role} "
					next
				end

				# 绘制旗格
			  print " %s " % GEZI  
			end
			puts
		end
	end

	def win!(winner)
	  puts '*' * 20
	  puts ' Winner:  ' + winner.to_s
	  puts '*' * 20
	end

end

if __FILE__ == $0

  canvas = Canvas.new
  canvas.draw

  client = Client.new('localhost', 4444)

	client.listen_to_server do |message|
	  puts 

		if message.include? 'Role:'
		  canvas.role = message[5,1].gsub('Role:', '')
		elsif message.include? 'Win:'
		  winner = message.gsub('Win:', '')
			canvas.win!(winner)
			exit
		else
		  message.split('|').each do |s|
			  role = s[0]
				x    = s[2, 5].split(',')[0].to_i
				y    = s[2, 5].split(',')[1].to_i

        unless canvas.eyes.find{|e| e.x == x and e.y == y}
			    canvas.eyes << Eye.new(x, y, role)
				end
			end

      canvas.redraw
		end
	end

	while c = gets
	  client.send(c)
	end

end
