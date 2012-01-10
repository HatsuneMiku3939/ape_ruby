
module APE
	class CollisionDetector
		@@cpa = nil
		@@cpb = nil
		@@coll_normal = nil
		@@coll_depth = nil

		def self.test(obj_a, obj_b)
			return if obj_a.fixed && obj_b.fixed
			
			if obj_a.multisample == 0 && obj_b.multisample == 0
				norm_vs_norm(obj_a, obj_b)
			elsif obj_a.multisample > 0 && obj_b.multisample == 0
				samp_vs_norm(obj_a, obj_b)
			elsif obj_b.multisample > 0 && obj_a.multisample == 0
				samp_vs_norm(obj_b, obj_a)
			elsif obj_a.multisample == obj_b.multisample
				samp_vs_samp(obj_a, obj_b)
			else
				norm_vs_norm(obj_a, obj_b)			
			end	
		end
		
		def self.norm_vs_norm(obj_a, obj_b)
			obj_a.samp.copy(obj_a.curr)
			obj_b.samp.copy(obj_b.curr)
			if test_types(obj_a, obj_b)
				CollisionResolver.resolve(@@cpa, @@cpb, @@coll_normal, @@coll_depth)
				return true
			end
			return false
		end
		
		def self.samp_vs_norm(obj_a, obj_b)
			return if norm_vs_norm(obj_a, obj_b)

			s = 1.0 / (obj_a.multisample + 1)
			t = s
			
			obj_b.samp.copy obj_b.curr
			
			obj_a.multisample.times do |i|
				obj_a.samp.set_to( obj_a.prev.x + t * (obj_a.curr.x - obj_a.prev.x),
								   obj_a.prev.y + t * (obj_a.curr.y - obj_a.prev.y))
								   
				if test_types(obj_a, obj_b)
					CollisionResolver.resolve(@@cpa, @@cpb, @@coll_normal, @@coll_depth)
					return
				end
				t += s
			end
		end
		
		def self.samp_vs_samp(obj_a, obj_b)
			return if norm_vs_norm(obj_a, obj_b)

			s = 1.0 / (obj_a.multisample + 1)
			t = s
			
			obj_a.multisample.times do |i|
				obj_a.samp.set_to( obj_a.prev.x + t * (obj_a.curr.x - obj_a.prev.x),
								   obj_a.prev.y + t * (obj_a.curr.y - obj_a.prev.y))

				obj_b.samp.set_to( obj_b.prev.x + t * (obj_b.curr.x - obj_b.prev.x),
								   obj_b.prev.y + t * (obj_b.curr.y - obj_b.prev.y))
								   
				if test_types(obj_a, obj_b)
					CollisionResolver.resolve(@@cpa, @@cpb, @@coll_normal, @@coll_depth)
					return
				end
				t += s
			end
		end
		
		
		def self.test_types(obj_a, obj_b)
			case
			when obj_a.kind_of?(RectangleParticle) && obj_b.kind_of?(RectangleParticle)
				return test_OBB_vs_OBB(obj_a, obj_b)
			when obj_a.kind_of?(CircleParticle) && obj_b.kind_of?(CircleParticle)
				return test_circle_vs_circle(obj_a, obj_b)
			when obj_a.kind_of?(RectangleParticle) && obj_b.kind_of?(CircleParticle)
				return test_OBB_vs_circle(obj_a, obj_b)
			when obj_a.kind_of?(CircleParticle) && obj_b.kind_of?(RectangleParticle)
				return test_OBB_vs_circle(obj_b, obj_a)
			end
			
			return false
		end
		
		
		def self.test_OBB_vs_OBB(ra, rb)
			@@coll_depth = 1.0 / 0 # positive infinity
			
			2.times do |i|
				axis_a = ra.axes[i]
				depth_a = test_intervals(ra.get_projection(axis_a), rb.get_projection(axis_a))
				return false if depth_a == 0
				
				axis_b = rb.axes[i]
				depth_b = test_intervals(ra.get_projection(axis_b), rb.get_projection(axis_b))
				return false if depth_b == 0

				abs_a = depth_a.abs
				abs_b = depth_b.abs
				
				if abs_a < @@coll_depth.abs || abs_b < @@coll_depth.abs
					altb = abs_a < abs_b
					@@coll_normal = altb ? axis_a : axis_b
					@@coll_depth = altb ? depth_a : depth_b
				end
			end
			
			@@cpa = ra
			@@cpb = rb	
			return true
		end
		
		def self.test_OBB_vs_circle(ra, ca)
			@@coll_normal = Vector.new(0, 0)
			@@coll_depth = 1.0 / 0 # positive infinity 
			depths = []
			
			# first go through the axes of the rectangle
			2.times do |i|
				box_axis = ra.axes[i]
				depth = test_intervals(ra.get_projection(box_axis), ca.get_projection(box_axis))
				return false if depth == 0
				
				if depth.abs < @@coll_depth.abs
					@@coll_normal = box_axis
					@@coll_depth = depth
				end
				depths[i] = depth
			end
			
			# determine if circle's center is in a vertex region
			r = ca.radius
			if depths[0].abs < r && depths[1].abs < r
				vertex = closest_vertex_on_OBB(ca.samp, ra)
				
				# get the distance from the closet vertex on rect to circle center
				@@coll_normal = vertex.minus ca.samp
				mag = @@coll_normal.magnitude
				@@coll_depth = r - mag
				
				if @@coll_depth > 0
					# there is a collision in one of the vertex regisons
					@@coll_normal.div_equals(mag)
				else
					# ra is in vertex region, but is not colliding
					return false
				end
			end
			
			@@cpa = ra
			@@cpb = ca
			return true            
		end    
		
		def self.test_circle_vs_circle(ca, cb)
			depth_x = test_intervals(ca.get_interval_x, cb.get_interval_x)
			return false if depth_x == 0
			
			depth_y = test_intervals(ca.get_interval_y, cb.get_interval_y)
			return false if depth_y == 0
			
			@@coll_normal = ca.samp.minus(cb.samp)
			mag = @@coll_normal.magnitude
			@@coll_depth = (ca.radius + cb.radius) - mag
			
			if @@coll_depth > 0
				@@coll_normal.div_equals(mag)
				@@cpa = ca
				@@cpb = cb
				return true
			end
			
			return false
		end
		
		def self.test_intervals(interval_a, interval_b)
			return 0 if interval_a.max < interval_b.min
			return 0 if interval_b.max < interval_a.min
			
			len_a = interval_b.max - interval_a.min
			len_b = interval_b.min - interval_a.max
			
			return (len_a.abs < len_b.abs) ? len_a : len_b
		end
		
		def self.closest_vertex_on_OBB(p, r)
			d = p.minus(r.samp)
			q = Vector.new(r.samp.x, r.samp.y)
			
			2.times do |i|
				dist = d.dot r.axes[i]
				
				if dist >= 0
					dist = r.extents[i]
				elsif dist < 0
					dist = -r.extents[i]
				end
				
				q.plus_equals(r.axes[i].mult(dist))
			end
			
			return q
		end
	end
end

