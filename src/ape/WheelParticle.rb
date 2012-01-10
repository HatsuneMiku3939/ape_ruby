
module APE
	class WheelParticle < CircleParticle
		def initialize(x, y, radius, render, fixed, mass = 1, elasticity = 0.3, friction = 0, traction = 1)
			super(x, y, radius, render, fixed, mass, elasticity, friction)

			@tan = Vector.new(0, 0)
			@norm_slip = Vector.new(0, 0)
			@rp = RimParticle.new(radius, 2)

			self.traction = traction
			@orientation = Vector.new(0, 0)
		end
	
		def speed
			@rp.speed
		end

		def speed=(s)
			@rp.speed = s	
		end

		def angular_velocity
			@rp.angular_velocity
		end

		def angular_velocity=(a)
			@rp.angular_velocity = a
		end

		def traction
			1 - @traction	
		end

		def traction=(t)
			@traction = 1 - t
		end

		def paint
			return if !@visible
				
			@render.paint(@curr.x, @curr.y, self.angle)
		end

		def init
			cleanup	
		end

		def radian
			@orientation.set_to(@rp.curr.x, @rp.curr.y)
			Math.atan2(@orientation.y, @orientation.x) + Math::PI
		end

		def angle
			radian * MathUtil.ONE_EIGHT_OVER_PI	
		end

		def update(dt)
			super(dt)
			@rp.update(dt)
		end

		def resolve_collision(mtd, vel, n, d, o, p)
			super(mtd, vel, n, d, o, p)
			resolve n.mult(MathUtil.sign(d * o))
		end

		def resolve(n)
			@tan.set_to(-@rp.curr.y, @rp.curr.x)
			@tan = @tan.normalize

			wheel_surface_velocity = @tan.mult(@rp.speed)
			combined_velocity = velocity.plus_equals(wheel_surface_velocity)
			cp = combined_velocity.cross n

			@tan.mult_equals(cp)
			@rp.prev.copy @rp.curr.minus(@tan)

			slip_speed = (1 - @traction) * @rp.speed
			@norm_slip.set_to(slip_speed * n.y, slip_speed * n.x)
			@curr.plus_equals(@norm_slip)
			@rp.speed *= @traction
		end
	end
end
