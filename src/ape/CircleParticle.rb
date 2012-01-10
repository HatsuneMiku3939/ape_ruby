
module APE
	class CircleParticle < AbstractParticle
		attr_reader :radius
		
		def initialize(x, y, _radius, render, fixed = false, mass = 1, elasticity = 0.3, friction = 0)
			super(x, y, fixed, mass, elasticity, friction, render) 
			self.radius = _radius
		end

		def radius=(r)
			@radius = r

			@render.set_geometry(@radius)
		end
		
		def init
			cleanup
		end

		def set_style(line_color = [0, 0, 0], line_alpha = 255, fill_color = [255, 255, 255], fill_alpha = 255)
			super
			@render.set_style(line_color, line_alpha, fill_color, fill_alpha)	
		end

		def paint
			return if !@visible

			@render.paint(@curr.x, @curr.y)
		end
		
		def get_projection(axis)
			c = @samp.dot(axis)
			@interval.min = c - @radius
			@interval.max = c + @radius
			
			return @interval
		end
		
		def get_interval_x
			@interval.min = @samp.x - @radius
			@interval.max = @samp.x + @radius
			
			return @interval
		end
		
		def get_interval_y
			@interval.min = @samp.y - @radius
			@interval.max = @samp.y + @radius
			
			return @interval
		end
	end
end
