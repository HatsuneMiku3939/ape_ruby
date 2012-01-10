module APE
	class Vector
		attr_accessor :x, :y
		
		def initialize(px, py)
			@x = px
			@y = py
		end
		
		def set_to(px, py)
			@x = px
			@y = py
		end
		
		def copy(v)
			@x = v.x
			@y = v.y
		end    
		
		def dot(v)
			return @x * v.x + @y * v.y
		end
		
		def cross(v)
		   return @x * v.y - @y * v.x
		end
		
		def plus(v)
			return Vector.new @x + v.x, @y + v.y
		end
		
		def plus_equals(v)
			@x += v.x
			@y += v.y
			return self
		end
		
		def minus(v)
			return Vector.new(@x - v.x, @y - v.y)
		end
		
		def minus_equals(v)
			@x -= v.x
			@y -= v.y
			return self
		end
		
		def mult(s)
			return Vector.new @x * s, @y * s
		end
		
		def mult_equals(s)
			@x *= s
			@y *= s
			return self
		end
		
		def times(v)
			return Vector.new @x * v.x, @y * v.y
		end
		
		def div_equals(s)
			s = 0.0001 if s == 0
			@x /= s
			@y /= s
			return self
		end
		
		def magnitude
			return Math.sqrt @x * @x + @y * @y
		end
		
		def distance(v)
			temp = minus(v)
			delta = temp.magnitude
			return delta
		end
		
		def normalize
			m = magnitude
			m = 0.0001 if m == 0
			return mult(1.0 / m)
		end

		def normalize_equals
			m = magnitude
			m = 0x0001 if m == 0
			return mult_equals(1 / m)
		end
		
		def to_s
			"#{@x} : #{@y}"
		end
	end
end
