
module APE    
	class Composite < AbstractCollection
		def initialize
			super
			@delta = Vector.new(0, 0)
		end
		
		def rotate_by_radian(angle_radians, center)
			radius = nil
			angle = nil
			
			size = @particles.size
			size.times do |i|
				p = @particles[i]
				radius = p.center.distance(center)
				angle = get_relative_angle(center, p.center) + angle_radians
				
				p.px = Math.cos(angle) * radius + center.x
				p.py = Math.sin(angle) * radius + center.y
			end
		end
		
		def rotate_by_angle(angle_degrees, center)
			angle_radians = angle_degrees * MathUtil.PI_OVER_ONE_EIGHTY 
			rotate_by_radian(angle_radians, center)
		end
		
		def fixed
			return false if @particles.detect { |p| not p.fixed } 
			return true
		end
		
		def get_relative_angle(center, p)
			@delta.set_to p.x - center.x, p.y - center.y
			return Math.atan2(@delta.y, @delta.x)
		end
	end
end
