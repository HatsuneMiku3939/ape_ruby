
module APE
	class AbstractParticle < AbstractItem
		attr_accessor :curr, :prev, :samp, :interval
		attr_accessor :multisample, :fixed, :collidable 
		attr_reader :mass, :friction
		attr_reader :render
		
		def initialize(x, y, is_fixed, _mass, elasticity, friction, render)
			super()
			
			@interval = Interval.new(0, 0)        
			
			@curr = Vector.new(x, y)
			@prev = Vector.new(x, y)
			@samp = Vector.new(0, 0)
			@temp = Vector.new(0, 0)
			@fixed = is_fixed
			
			@forces = Vector.new(0, 0)
			@force_list = []

			@collision = Collision.new(Vector.new(0, 0), Vector.new(0, 0))
			@collidable = true
			@first_collision = false
			
			self.mass = _mass
			self.elasticity = elasticity
			self.friction = friction
			@render = render

			set_style()
			
			@center = Vector.new(0, 0)
			@multisample = 0
		end

		def mass=(m)
			raise ArgumentError, "override this method" if m <= 0		
			@mass = m;
			@inv_mass = 1.0 / @mass
		end
		
		def elasticity
			@kfr
		end
		
		def elasticity=(k)
			@kfr = k
		end
		
		def center
			@center.set_to(px, py)
			return @center
		end
		
		def friction=(f)
			raise ArgumentError, "Legal friction must be >= 0 and <=1" if (f < 0 || f > 1)
			@friction = f
		end
		
		def position     
			Vector.new(@curr.x, @curr.y)
		end
		
		def position=(p)
			@curr.copy(p)
			@prev.copy(p)
		end
		
		def px
			@curr.x
		end
		
		def px=(x)
			@curr.x = x
			@prev.x = x
		end
		
		def py
			@curr.y
		end
		
		def py=(y)
			@curr.y = y
			@prev.y = y
		end
		
		def velocity
			@curr.minus(@prev)
		end
		
		def velocity=(v)
			@prev = @curr.minus(v)
		end
		
		def set_display(d, offset_x = 0, offset_y = 0, rotation = 0)
		end
		
		def add_force(f)
			@force_list << f
		end
		
		def update(dt2)
			return if @fixed
			
			accumulate_forces
			
			@temp.copy(@curr)

			nv = @curr.minus(@prev).plus(@forces.mult_equals(dt2))
			@curr.plus_equals(nv.mult_equals(@ape.damping))

			@prev.copy(@temp)
			
			clear_forces
		end

		def reset_first_collision
			@first_collision = false
		end
		
		def init_display
		end
		
		def get_components(collision_normal)
			vel = velocity
			vdotn = collision_normal.dot(vel)

			@collision.vn = collision_normal.mult(vdotn)
			@collision.vt = vel.minus(@collision.vn)
			return @collision
		end
		
		def resolve_collision(mtd, vel, n, d, o, p)
			test_particle_events(p)

			return if @fixed || (!@solid || (!p.solid))

			@curr.copy(@samp)
			@curr.plus_equals(mtd)
			self.velocity = vel
		end

		def test_particle_events(p)
			notify(CollisionEvent::COLLIDE, CollisionEvent.new(false, false, p))

			if !@first_collision && count_listeners(CollisionEvent::FIRST_COLLIDE) > 0
				@first_collision = true
				notify(CollisionEvent::FIRST_COLLIDE, CollisionEvent.new(false, false, p))
			end
		end
		
		def inv_mass
			return @fixed ? 0 : @inv_mass
		end

		private
		def accumulate_forces
			len = @force_list.size
			
			@force_list.each do |f|
				@forces.plus_equals(f.get_value(@inv_mass))
			end

			@ape.forces.each do |f|
				@forces.plus_equals(f.get_value(@inv_mass))
			end
		end

		def clear_forces
			@force_list = []
			@forces.set_to(0, 0)
		end
	end
end
