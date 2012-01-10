module APE
	class VectorForce < IForce
		attr_writer :vx, :vy

		def initialize(use_mass, vx, vy)
			@fvx = vx
			@fvy = vy

			@scale_mass = use_mass

			@value = Vector.new(vx, vy)
		end

		def use_mass=(b)
			@scale_mass = b
		end

		def get_value(inv_mass)
			@value.set_to(@fvx * inv_mass, @fvy * inv_mass) if @scale_mass
			return @value
		end
	end
end
