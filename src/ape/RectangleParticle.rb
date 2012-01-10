
module APE
	class RectangleParticle < AbstractParticle
		attr_reader :radian, :axes, :extents
		
		def initialize(x, y, _width, _height, render, rotation = 0, fixed = false, mass = 1, elasticity = 0.3, friction = 0)
			super(x, y, fixed, mass, elasticity, friction, render)
			
			@extents = [_width / 2.0, _height / 2.0]
			@axes = [Vector.new(0, 0), Vector.new(0, 0)]
			self.radian = rotation

			@render.set_geometry(self.width, self.height)
		end
		
		def radian=(t)
			@radian = t
			set_axes(t)
		end
		
		def angle
			@radian * MathUtil.ONE_EIGHT_OVER_PI
		end
		
		def angle=(a)
			self.radian = a * MathUtil.PI_OVER_ONE_EIGHTY
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

			@render.paint(@curr.x, @curr.y, angle)
		end
		
		def width
		   @extents[0] * 2.0 
		end    
		
		def width=(w)
			@extents[0] = w / 2.0

			@render.set_geometry(self.width, self.height)
		end 
		
		def height=(h)
			@extents[1] = h / 2.0

			@render.set_geometry(self.width, self.height)
		end
		
		def height
			@extents[1] * 2.0
		end
		
		def get_projection(axis)
			radius = extents[0] * (axis.dot(axes[0])).abs +
				     extents[1] * (axis.dot(axes[1])).abs
			c = @samp.dot axis

			@interval.min = c - radius
			@interval.max = c + radius

			return @interval         
		end
		
		def set_axes(t)
			s = Math.sin t
			c = Math.cos t

			@axes[0].x = c
			@axes[0].y = s
			@axes[1].x = -s
			@axes[1].y = c
		end
	end
end
