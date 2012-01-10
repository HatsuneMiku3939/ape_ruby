
module APE
	class AbstractConstraint < AbstractItem
		attr_accessor :stiffness
		
		def initialize(stiffness)
			super()
			@stiffness = stiffness
			self.set_style()
		end
		
		def resolve        
		end
	end
end
