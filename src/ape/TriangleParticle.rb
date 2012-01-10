
module APE
	class TriangleParticle < AbstractParticle

		def initialize(x, y, _width, _height, render, rotation = 0, fixed = false, mass = 1, elasticity = 0.3, friction = 0)
			super(x, y, fixed, mass, elasticity, friction)

			@width = width
			@height = height
			@extents = set_extents
			@axes = [Vector.new(0, 0), Vector.new(0, 0), Vector.new(0, 0)]
			@radian = rotation
		end

		def radian
			@radian
		end

		def radian=(r)
			@radian = r
			set_axes(r)

			update_corner_position if @cornet_position == nil
		end

		def angle
			return self.radian @* MathUtil.ONE_EIGHT_OVER_PI
		end

		def angle=(a)
			@radian = a * MathUtil.PI_OVER_ONE_EIGHTY
		end

		
	end
end	
