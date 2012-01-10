class Timer
	def initialize
		@start_ticks = 0
		@paused_ticks = 0
		@paused = false
		@started = false
	end
	
	def start
		@started = true
		@paused = false
		
		@start_ticks = SDL.get_ticks
	end
	
	def stop
		@paused = false
		@started = false
	end
	
	def get_ticks
		if @started
			if @paused
				return @paused_ticks
			else
				return SDL.get_ticks - @start_ticks
			end
		end
		
		return 0
	end
	
	def pause
		if @started and !@paused
			@paused = true 
			@paused_ticks = SDL.get_ticks - @start_ticks
		end
	end
	
	def unpause
		if @paused
			@paused = false
			@start_ticks = SDL.get_ticks - @paused_ticks
			
			@paused_ticks = 0
		end
	end
	
	def start?
		@started
	end
	
	def pause?
		@paused
	end
end
