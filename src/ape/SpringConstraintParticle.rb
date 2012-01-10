module APE
	class SpringConstraintParticle < RectangleParticle
		attr_accessor :rect_scale, :rect_height, :fixed_end_limit, :parent
		
		def initialize(p1, p2, p, rect_height, rect_scale, scale_to_length, render)
			super(0, 0, 0, 0, render, 0, false)
			
			@p1 = p1
			@p2 = p2
			
			@lambda = Vector.new(0, 0)
			@avg_velocity = Vector.new(0, 0)
			
			@parent = p
			@rect_scale = rect_scale
			@rect_height = rect_height
			@scale_to_length = scale_to_length
			
			@fixed_end_limit = 0
			@rca = Vector.new(0, 0)
			@rcb = Vector.new(0, 0)
			@s = nil
		end
		
		def mass
			(@p1.mass + @p2.mass) / 2.0
		end
		
		def elasticity
			(@p1.elasticity + @p2.elasticity) / 2.0
		end
		
		def friction
			(@p2.friction + @p2.friction) / 2.0
		end
		
		def velocity
			p1v = @p1.velocity
			p2v = @p2.velocity
			
			@avg_velocity.set_to((p1v.x + p2v.x) / 2.0, (p1v.y + p2v.y) / 2.0)
			return @avg_velocity
		end
		
		def init
			super	
		end

		def paint
			super
		end

		def inv_mass
			return 0 if @p1.fixed && @p2.fixed
			1.0 / ((@p1.mass + @p2.mass) / 2)
		end

		def fixed
			@parent.fixed
		end

		def update_position
			c = @parent.center
			@curr.set_to(c.x, c.y)

			self.width = @scale_to_length ? @parent.curr_length * @rect_scale : @parent.rest_length * @rect_scale
			self.height = rect_height
			self.radian = @parent.radian
		end

		def resolve_collision(mtd, vel, n, d, o, p)
			test_particle_events(p)
			return if self.fixed || !p.solid
			
			t = get_contact_point_param p
			c1 = (1 - t)
			c2 = t

			if @p1.fixed
				return if c2 <= fixed_end_limit

				@lambda.set_to(mtd.x / c2, mtd.y / c2)
				@p2.curr.plus_equals @lambda
				@p2.velocity = vel
			elsif @p2.fixed
				return if c1 <= fixed_end_limit
				
				@lambda.set_to(mtd.x / c1, mtd.y / c1)
				@p1.curr.plus_equals @lambda
				@p1.velocity = vel
			else
				denom = c1 * c1 + c2 * c2
				return if denom == 0
				@lambda.set_to(mtd.x / denom, mtd.y / denom)

				@p1.curr.plus_equals @lambda.mult(c1)
				@p2.curr.plus_equals @lambda.mult(c2)

				if t == 0.5
					@p1.velocity = vel
					@p2.velocity = vel
				else
					corr_particle = (t < 0.5) ? @p1 : @p2
					corr_particle.velocity = vel
				end
			end			
		end
		
		private
		def closest_param_point(c)
			ab = @p2.curr.minus @p1.curr
			t = ab.dot(c.minus(@p1.curr)) / ab.dot(ab)
			return MathUtil.clamp(t, 0.0, 1.0)
		end
		
		def get_contact_point_param(p)
			t = nil
			shortest_index = nil
			param_list = Array.new
			shortest_distance = 1.0 / 0				# postive infinity 

			if p.kind_of?(CircleParticle)
				t = closest_param_point(p.curr)
			elsif p.kind_of?(RectangleParticle)
				4.times	do |i|
					set_corners p, i

					d = closest_pt_segment_segment
					if d < shortest_distance
						shortest_distance = d
						shortest_index = i
						param_list[i] = @s
					end	
				end
				t = param_list[shortest_index]
			end
			
		 	return t
		end

		def set_corners(r, i)
			rx = r.curr.x
			ry = r.curr.y
			
			axes = r.axes
			extents = r.extents	

			ae0_x = axes[0].x * extents[0]
			ae0_y = axes[0].y * extents[0]
			ae1_x = axes[1].x * extents[1]
			ae1_y = axes[1].y * extents[1]

			emx = ae0_x - ae1_x
			emy = ae0_y - ae1_y
			epx = ae0_x + ae1_x
			epy = ae0_y + ae1_y

			if i == 0
				@rca.x = rx - epx
				@rca.y = ry - epy
				@rcb.x = rx + emx
				@rcb.y = ry + emy
			elsif i == 1
				@rca.x = rx + emx
				@rca.y = ry + emy
				@rcb.x = rx + epx
				@rcb.y = ry + epy
			elsif i == 2
				@rca.x = rx + epx
				@rca.y = ry + epy
				@rcb.x = rx - emx
				@rcb.y = ry - emy
			elsif i == 3	
				@rca.x = rx - emx
				@rca.y = ry - emy
				@rcb.x = rx - epx
				@rcb.y = ry - epy
			end	
		end

		def closest_pt_segment_segment
			pp1 = @p1.curr
			pq1 = @p2.curr
			pp2 = @rca
			pq2 = @rcb

			d1 = pq1.minus(pp1)
			d2 = pq2.minus(pp2)
			r = pp1.minus(pp2)

			t = nil
			a = d1.dot(d1)
			e = d2.dot(d2)
			f = d2.dot(r)

			c = d1.dot(r)
			b = d1.dot(d2)
			denom = a * e - b * b

			if denom != 0.0
				@s = MathUtil.clamp((b * f - c * e) / denom, 0.0, 1.0)
			else
				@s = 0.5
			end
			t = (b * @s + f) / e
			
			if t < 0
				t = 0
				@s = MathUtil.clamp(-c / a, 0.0, 1.0)
			elsif t > 0
				t = 1
				@s = MathUtil.clamp((b - c) / a, 0.0, 1.0)
			end
			
			c1 = pp1.plus(d1.mult(@s))
			c2 = pp2.plus(d2.mult(t))
			c1mc2 = c1.minus(c2)
			
			c1mc2.dot(c1mc2)
		end
	end
end
