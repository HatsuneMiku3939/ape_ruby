
module APE    
	class MathUtil
		@@ONE_EIGHT_OVER_PI = 180 / Math::PI
		@@PI_OVER_ONE_EIGHTY = Math::PI / 180
		
		def self.ONE_EIGHT_OVER_PI
			@@ONE_EIGHT_OVER_PI
		end
		
		def PI_OVER_ONE_EIGHTY
			@@PI_OVER_ONE_EIGHTY
		end
		
		def self.clamp(n, min, max)
			return min if n < min
			return max if n > max
			return n
		end
		
		def self.sign(val)
			return -1 if val < 0
			return 1
		end    
	end
end
