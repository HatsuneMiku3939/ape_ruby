require 'singleton'

module APE
	class APEngine
		include Singleton
		
		APE_ENGINE_VERSION = "0.50a"

		attr_accessor :forces

		def init(dt = 0.25)
			#puts "APE ENGINE #{@@APE_ENGINE_VERSION} CREATED"
			#puts "Original Action Script Version By Alec Cove"
			#puts "Ruby/SDL port By DMW"

			@time_step = dt * dt
			@num_groups = 0
			@groups = []
			
			@forces = []
			@container = []	
			self.damping = 1
			
			@constraint_cycles = 0
			@constraint_collision_cycles = 1
		end
		
		def damping
			@damping
		end
		
		def damping=(d)
			raise ArgumentError, "damping value should be >=0 and <=1." if d < 0 or d > 1
			@damping = d
		end
		
		def constraint_cycles
			@constraint_cycles
		end
		
		def constraint_cycles=(num_cycles)
			@constraint_cycles = num_cycles
		end
		
		def constraint_collision_cycles
			@constraint_collision_cycles
		end
		
		def constraint_collision_cycles=(num_cycles)
			@constraint_collision_cycles = num_cycles
		end
		
		def container        
		end
		
		def container=(d)
		end
		
		def add_force(f)
			@forces << f
		end

		def remove_force(v)
			@forces.delete(f)
		end

		def remove_all_froces()
			@forces = []
		end
		
		def add_group(g)
			@groups.push g
			g.is_parented = true
			@num_groups = @num_groups + 1
			g.init
		end
		
		def remove_group(g)
			@groups.delete g
			g.is_parented = false
			@num_groups = @num_groups - 1
			g.cleanup
		end
		
		def step
			integrate
			@constraint_cycles.times { satisfy_constraints }
			@constraint_collision_cycles.times do
				satisfy_constraints
				check_collisions
			end
		end
		
		def paint
			size = @groups.size
			size.times do |i|
				g = @groups[i]
				g.paint
			end
		end
		
		def integrate
			size = @groups.size
			size.times do |i|
				g = @groups[i]
				g.integrate @time_step
			end
		end
		
		def satisfy_constraints
			size = @groups.size
			size.times do |i|
				g = @groups[i]
				g.satisfy_constraints
			end
		end
		
		def check_collisions
			size = @groups.size
			size.times do |i|
				g = @groups[i]
				g.check_collisions
			end	
		end
	end
end
