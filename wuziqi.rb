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

	  win?
	end

	# 思路：寻找有没有连续的5个棋子。20个行，20个列，还有斜行24个，共找64次
	def win?

	  # 行
   	(1..20).each do |i|
		  count = 0
		  (1..20).each do |j|
			  eye = @eyes.find{|e| e.x == i and e.y == j}
				if eye and eye.used?(@role)
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
			  eye = @eyes.find{|e| e.x == i and e.y == j}
				if eye and eye.used?(@role)
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
  		  	eye = @eyes.find{|e| e.x == i and e.y == j}
  				if eye and eye.used?(@role)
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
  		  	eye = @eyes.find{|e| e.x == i and e.y == j}
  				if eye and eye.used?(@role)
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

	def win_exit!
	  puts "-----#{@role} win!-----"
	  exit
	end

end

if __FILE__ == $0
  canvas = Canvas.new(:B)
  canvas.draw

  while(true)
    print "#{canvas.role}:"
	  a = gets
    arr = a.split(',')
		eye = Eye.new(arr[0].to_i, arr[1].to_i)
    canvas.redraw(eye)
	end
end
