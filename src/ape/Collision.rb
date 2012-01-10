
module APE
	class Collision
		attr_accessor :vn, :vt
		
		def initialize(vn, vt)
		   @vn = vn
		   @vt = vt 
		end

		def to_s
			"#{vn}, #{vt}"
		end
	end
end
