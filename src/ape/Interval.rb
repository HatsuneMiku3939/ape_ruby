
module APE
	class Interval
		attr_accessor :min, :max
		
		def initialize(min, max)
			@min = min
			@max = max
		end   
		
		def to_s
			"#{@min} : #{@max}"
		end
	end
end
