
module APE
	class Group < AbstractCollection
		attr_reader :composites, :collision_list
		attr_accessor :collide_internal
		
		def initialize(collide_internal = false)
			super()
			@composites = []
			@collision_list = []
			@collide_internal = collide_internal
		end
		
		def init
			super

			size = @composites.size
			size.times do |i|
				c = @composites[i]
				c.init
			end
		end
		
		def add_composite(c)
			@composites.push c
			c.is_parented = true
			c.init if is_parented
		end
		
		def remove_composite(c)
			@composites.delete(c)
			c.cleanup
		end
		
		def paint
			super

			size = @composites.size
			size.times do |i|
				c = @composites[i]
				c.paint
			end	
		end
		
		def add_collidiable(g)
			@collision_list.push(g)
		end
		
		def remove_collidiable(g)
			@collision_list.delete(g)
		end
		
		def add_collidable_list(list)
			@collision_list += list
		end
		
		def get_all
			return @particles.concat(@constraints).concat(@composites);
		end
		
		def cleanup
			super

			size = @composites.size
			size.times do |i|
				c = @composites[i]
				c.cleanup
			end	
		end
		
		def integrate(dt2)
			super(dt2)

			size = @composites.size
			size.times do |i|
				c = @composites[i]
				c.integrate(dt2)
			end
		end
		
		def satisfy_constraints
			super

			size = @composites.size
			size.times do |i|
				c = @composites[i]
				c.satisfy_constraints
			end	
		end
		
		def check_collisions
			check_collision_group_internal  if @collide_internal
			
			size = @collision_list.size
			size.times do |i|
				g = @collision_list[i]
				next if g == nil
				check_collision_vs_group(g)
			end
		end
		
		private
		def check_collision_group_internal
			check_internal_collisions
			
			ca = nil
			cb = nil
			clen = @composites.size
			clen.times do |j|
				ca = @composites[j]
				next if ca == nil
				ca.check_collisions_vs_collection(self)
				
				(j + 1).step(clen-1, 1) do |i|
					cb = @composites[i]
					ca.check_collisions_vs_collection(cb) if cb != nil
				end
			end
		end
		
		def check_collision_vs_group(g)
			check_collisions_vs_collection(g)
			
			gc = nil	
			clen = @composites.size
			gclen = g.composites.size

			clen.times do |i|
				c = @composites[i]
				next if c == nil
				c.check_collisions_vs_collection(g)
				
				gclen.times do |j|
					gc = g.composites[j]
					next if gc == nil
					c.check_collisions_vs_collection(gc)
				end				
			end

			gclen.times do |j|
				gc = g.composites[j]
				next if gc == nil
				check_collisions_vs_collection(gc)
			end
		end
	end
end
