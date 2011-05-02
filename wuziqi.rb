require './client'

class Eye
  attr_reader :x, :y, :role

	def initialize(x, y)
	  @x, @y = x, y
		@occupy = false 
	end

	def use_me(role)
	  @occupy = true
	  @role   = role
	end

	def used?(role)
	  @occupy and @role == role
	end

end

class Canvas
  attr_reader :role
	
	def initialize(role)
	  # 全部棋子
	  @eyes = [] 

    @role = role
		@row_number = 20
	end

	def draw
		(1..20).each do |i|
		  (1..20).each do |j|
			  print ' o '  
			end
			puts
		end
	end

	def redraw(eye)

		(1..20).each do |i|
		  (1..20).each do |j|
			  # 绘制已经下的棋子
			  if eee = @eyes.find{|e| e.x == i and e.y == j} and eee.used?(@role)
				  print " #{@role} "
				#	绘制刚下的棋子
			  elsif eye.x == i and eye.y == j
				  print " #{@role} "

					e = Eye.new(i, j)
					e.use_me(@role)
					@eyes << e
				# 绘制旗格
				else
			    print ' o '  
				end
			end
			puts
		end

	  if win?
	    win_exit!
		end
	end

	def win?
	  false
	end
	
	def win_exit!
	  puts "-----#{@role} win!-----"
	  exit
	end

end

if __FILE__ == $0

	trap("INT") { interrupted = true }

  if ARGV.size == 0
	  puts "Usage: ruby wuziqi.rb black|white" 
	end

  role = ARGV[0] == 'black' ? :B : :A
  canvas = Canvas.new(role)
  canvas.draw

  client = Client.new('localhost', 4444)
	client.listen_to_server do |message|
    puts message
    arr = message.split(',')
		puts arr.inspect
		eye = Eye.new(arr[0].to_i, arr[1].to_i)
    canvas.redraw(eye)
	end

	while c = gets
    arr = c.split(',')
		eye = Eye.new(arr[0].to_i, arr[1].to_i)
    canvas.redraw(eye)

	  client.send(c)
	end

end
