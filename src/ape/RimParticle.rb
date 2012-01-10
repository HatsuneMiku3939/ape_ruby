module APE
	class RimParticle
		attr_accessor :curr, :prev
		def initialize(r, mt)
			@curr = Vector.new r, 0
			@prev = Vector.new 0, 0

			@sp = 0
			@av = 0

			@max_torque = mt
			@wr = r
			@ape = APEngine.instance 
		end

		def speed
			@sp
		end
	
		def speed=(s)
			@sp = s
		end

		def angular_velocity
			@av
		end

		def angular_velocity=(s)
			@av = s
		end

		def update(dt)
			@sp = [-@max_torque, [@max_torque, @sp + @av].min].max

			dx = -@curr.y
			dy = @curr.x
			
			len = Math.sqrt(dx * dx + dy * dy)
			dx /= len.to_f
			dy /= len.to_f

			@curr.x += @sp * dx
			@curr.y += @sp * dy

			ox = @prev.x
			oy = @prev.y
			px = @prev.x = @curr.x
			py = @prev.y = @curr.y

			@curr.x += @ape.damping * (px - ox)
			@curr.y += @ape.damping * (py - oy)
			
			clen = Math.sqrt @curr.x * @curr.x + @curr.y * @curr.y
			diff = (clen - @wr) / clen.to_f

			@curr.x -= @curr.x * diff
			@curr.y -= @curr.y * diff
		end
	end
end
