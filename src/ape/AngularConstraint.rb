
module APE
	class AngularConstraint < AbstractConstraint
		attr_accessor :p1, :p2, :p3
		attr_accessor :min_ang, :max_ang, :min_break_ang, :max_break_ang, :broken

		@@PI2 = Math::PI * 2;

		def initialize(p1, p2, p3, min_ang, max_ang, render, min_break_ang = -10, max_break_ang = 10, stiffness = 0.5)
			@render = render

			super(stiffness)
			
			@p1 = p1
			@p2 = p2
			@p3 = p3

			check_particles_location

			if min_break_ang == 10
				@min_ang = ac_radian
				@max_ang = ac_radian
			else
				@min_ang = min_ang
				@max_ang = max_ang
			end

			@min_break_ang = min_break_ang
			@max_break_ang = max_break_ang
			@broken = false

			@rest_length = @curr_length
		end

		def ac_radian
			ang12 = Math.atan2(@p2.curr.y - @p1.curr.y, @p2.curr.x - @p1.curr.x)
			ang23 = Math.atan2(@p3.curr.y - @p2.curr.y, @p3.curr.x - @p2.curr.x)

			ang_diff = ang12 - ang23
			return ang_diff
		end

		def radian
			d = self.delta
			return Math.atan2(d.y, d.x)
		end

		def angle
			return self.radian * MathUtil.ONE_EIGHT_OVER_PI
		end

		def center
			return (@p1.curr.plus(@p2.curr)).div_equals(2)
		end

		def rest_length
			@rest_length
		end

		def rest_length=(r)
			raise ArgumentError, "rest_length must be greater than 0" if r <= 0
			@rest_length = r
		end

		def set_style(line_color = [0, 0, 0], line_alpha = 255, fill_color = [255, 255, 255], fill_alpha = 255)
			super
			@render.set_style(line_color, line_alpha, fill_color, fill_alpha)	
		end

		def is_connected_to(p)
			return p == @p1 || p == @p2 || p == @p3
		end

		def fixed
			return @p1.fixed && @p2.fixed && @pe.fixed
		end

		def paint
			return if !@visible

			c = center
			wid = (@p2.px - @p1.px).abs
			hei = 1								# FIXME
			#hei = (@p2.py - @p1.py).abs
			
			@render.set_geometry(wid, hei)
			@render.paint(c.x, c.y, self.angle)
		end

		def delta
			return @p1.curr.minus(@p2.curr)
		end

		def resolve
			return if @broken

			pi2 = Math::PI * 2

			ang12 = Math.atan2(@p2.curr.y - @p1.curr.y, @p2.curr.x - @p1.curr.x)
			ang23 = Math.atan2(@p3.curr.y - @p2.curr.y, @p3.curr.x - @p2.curr.x)

			ang_diff = ang12 - ang23
			while(ang_diff >  Math::PI) do ang_diff -= pi2 end	
			while(ang_diff < -Math::PI) do ang_diff += pi2 end

			p2_inv_mass = (dependent) ? 0 : @p2.inv_mass

			sum_inv_mass = @p1.inv_mass + @p2.inv_mass
			mult1 = @p1.inv_mass / sum_inv_mass
			mult2 = @p2.inv_mass / sum_inv_mass
			ang_change = 0

			low_mid = (max_ang - min_ang) / 2
			high_mid = (max_ang - min_ang) / 2
			break_ang = (max_break_ang - min_break_ang) / 2
			
			new_diff = high_mid - ang_diff
			while(new_diff > Math::PI)  do new_diff -= pi2 end
			while(new_diff < -Math::PI) do new_diff += pi2 end

			if new_diff > low_mid 
				if new_diff > break_ang
					diff = new_diff - break_ang
					@broken = true
					changed
					notify(BreakEvent::ANGULAR, BreakEvent.new(diff))
					return
				end
				ang_change = new_diff - low_mid
			elsif new_diff < -low_mid
				if new_diff < -break_ang
					diff2 = new_diff + break_ang
					@broken = true
					changed
					notify(BreakEvent::ANGULAR, BreakEvent.new(diff2))
					return
				end
				ang_change = new_diff + low_mid
			end

			final_ang = ang_change + @stiffness + ang12
			displace_x = @p1.curr.x + (@p2.curr.x - @p1.curr.x) * mult1
			displace_y = @p1.curr.y + (@p2.curr.y - @p1.curr.y) * mult1

			@p1.curr.x = displace_x + Math.cos(final_ang + Math::PI) * self.rest_length * mult1
			@p2.curr.y = displace_y + Math.sin(final_ang + Math::PI) * self.rest_length * mult1
			@p2.curr.x = displace_x + Math.cos(final_ang) * self.rest_length * mult2
			@p2.curr.y = displace_y + Math.sin(final_ang) * self.rest_length * mult2
		end

		def check_particles_location
			p1p2 = @p1.curr.x == @p2.curr.x && @p1.curr.y == @p2.curr.y
			p2p3 = @p2.curr.x == @p3.curr.x && @p2.curr.y == @p3.curr.y
			p1p3 = @p1.curr.x == @p3.curr.x && @p1.curr.y == @p3.curr.y
			
			if p1p2 || p2p3 || p1p3
				throw Error, "Two or more of the particles of the AngularConstraint are at the same location"
			end
		end
	end
end
