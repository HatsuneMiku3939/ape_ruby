
module APE
	class SpringConstraint < AbstractConstraint
		attr_accessor :p1, :p2
		attr_reader :rest_length, :collidable
		
		def initialize(p1, p2, render, stiffness = 0.5, collidable = false, rect_height = 1, rect_scale = 1, scale_to_length = false)
			@render = render
			super(stiffness)
			
			@p1 = p1
			@p2 = p2
			check_particles_location

			self.rest_length = self.curr_length
			set_collidable(collidable, rect_height, rect_scale, scale_to_length)
		end
		
		def radian
			d = delta
			return Math.atan2(d.y, d.x)
		end
		
		def angle
			return radian * MathUtil.ONE_EIGHT_OVER_PI
		end
		
		def center
			return (@p1.curr.plus(@p2.curr)).div_equals(2)
		end

		def set_style(line_color = [0, 0, 0], line_alpha = 255, fill_color = [255, 255, 255], fill_alpha = 255)
			super
			@render.set_style(line_color, line_alpha, fill_color, fill_alpha)	
		end
		
		def rect_scale=(s)
			return if @scp == nil
			@scp.rect_scale = s
		end
		
		def rect_scale
			return @scp.rect_scale
		end

		def part1
			return @p1
		end
		
		def curr_length
			return @p1.curr.distance(@p2.curr)
		end
		
		def rect_height
			return @scp.rect_height
		end
		
		def rect_height=(h)
			return if @scp == nil
			@scp.rect_height = h
		end
		
		def rest_length=(r)
			raise ArgumentError, "restLength must be gre @scp.heightater than 0" if r <= 0
			@rest_length = r
		end

		def fixed_end_limit
			return @scp.fixed_end_limit
		end
		
		def fixed_end_limit=(f)
			return if @scp == nil
			@scp.fixed_end_limit = f
		end
		
		def set_collidable(b, _rect_height, _rect_scale, _scale_to_length = false)
			@collidable = b
			@scp = nil

			if @collidable
				@scp = SpringConstraintParticle.new(@p1, @p2, self, _rect_height, _rect_scale, _scale_to_length, @render) 
			end
		end
		
		def is_connected_to(p)
			return p == @p1 || p == @p2
		end
		
		def fixed
			return @p1.fixed && @p2.fixed
		end
		
		def init
			cleanup
			
			@scp.init if collidable
		end
		
		def paint
			if collidable
				@scp.paint
			else
				return if !@visible
				
				c = center
				wid = (@p2.px - @p1.px).abs
				hei = 1

				@render.set_geometry(wid, hei)
				@render.paint(c.x, c.y, self.angle)
			end
		end
			
		def delta
			res = @p1.curr.minus(@p2.curr)
			return res
		end
		
		def scp
			@scp
		end
		
		def resolve
			return if @p1.fixed && @p2.fixed
			
			delta_length = curr_length

			diff = (delta_length - rest_length) / (delta_length * (@p1.inv_mass + @p2.inv_mass))
			dmds = delta.mult(diff * @stiffness)

			@p1.curr.minus_equals(dmds.mult(@p1.inv_mass))
			@p2.curr.plus_equals(dmds.mult(@p2.inv_mass))
		end
		
		def check_particles_location
			@p2.curr.x += 0.0001 if @p1.curr.x == @p2.curr.x && @p1.curr.y == @p2.curr.y
		end
	end
end

