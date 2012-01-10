
module APE
	class AbstractCollection
		attr_reader :is_parented, :constraints, :is_parented, :particles
		attr_writer :is_parented
		
		def initialize
			@is_parented = false
			@particles = []
			@constraints = []
			@ape = APEngine.instance
		end
		
		def add_particles(p)
			@particles.push(p)
			p.init() if @is_parented
		end
		
		def remove_particle(p)
			@particles.delete p
			p.cleanup
		end
		
		def add_constraint(c)
			@constraints.push(c)
			c.init if @is_parented
		end
		
		def remove_constraint(c)
			@constraints.delete(c)
			c.cleanup
		end
		
		def init
			size = @particles.size
			size.times { |i| @particles[i].init }
			
			size = @constraints.size
			size.times { |i| @constraints[i].init }
		end
		
		def paint
			size = @particles.size
			size.times do |i|
				p = @particles[i]
				p.paint if !p.fixed || p.always_repaint
			end

			size = @constraints.size
			size.times do |i|
				c = @constraints[i]
				c.paint if !c.fixed || c.always_repaint
			end
		end   
		
		def cleanup
			size = @particles.size
			size.times do |i|
				p = @particles[i]
				p.cleanup
			end

			size = @constraints.size
			size.times do ie|
				c = @constraints[i]
				c.cleanup
			end
		end
		
		def get_all
	        return particles.concat(constraints);
		end
		
		def integrate(dt2)
			size = @particles.size
			size.times do |i|
				p = @particles[i]
				p.update dt2
			end
		end
		
		def satisfy_constraints
			size = @constraints.size
			size.times do |i|
				c = @constraints[i]
				c.resolve
			end
		end
		
		def check_internal_collisions
			plen = @particles.size
			plen.times do |j|
				pa = @particles[j]
				next if !pa.collidable
				
				(j+1).step(plen-1, 1) do |i|
					pb = @particles[i]
					CollisionDetector.test(pa, pb) if pb.collidable
				end
				
			   @constraints.size.times do |n|
				   c = @constraints[n]
				   
				   if c.collidable and !c.is_connected_to(pa)
					   c.scp.update_position
					   CollisionDetector.test pa, c.scp
				   end
			   end
			end
		end
		
		def check_collisions_vs_collection(ac)
			plen = @particles.size

			plen.times do |j|
				pga = @particles[j]
				next if pga == nil || !pga.collidable
				
				acplen = ac.particles.size
				acplen.times do |x|
					pgb = ac.particles[x]
					CollisionDetector.test pga, pgb if pgb != nil || pgb.collidable
				end
				
				acclen = ac.constraints.size
				acclen.times do |x|
					cgb = ac.constraints[x]
					
					if cgb != nil && cgb.collidable && !cgb.is_connected_to(pga)
						cgb.scp.update_position
						CollisionDetector.test pga, cgb.scp
					end
				end
			end	

			clen = @constraints.size
			clen.times do |j|
				cga = @constraints[j]
				next if cga == nil || !cga.collidable
				
				acplen = ac.particles.size
				acplen.times do |n|
					pgb = ac.particles[n]
					
					if pgb != nil || pgb.collidable && !cga.is_connected_to(pgb)
						cga.scp.update_position
						CollisionDetector.test pgb, cga.scp
					end
				end
			end
		end
	end
end
