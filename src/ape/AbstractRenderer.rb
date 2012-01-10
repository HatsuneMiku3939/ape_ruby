module APE
	class AbstractRenderer
		def initialize
			@line_color = [0, 0, 0]
			@line_alpha = 255

			@fill_color = [255, 255, 255]
			@fill_alpha = 255
			@dirty = true
		end
		
		def set_style(line_color, line_alpha, fill_color, fill_alpha)
			@line_color = line_color
			@line_alpha = line_alpha

			@fill_color = fill_color
			@fill_alpha = fill_alpha

			@dirty = true
		end
		
		private
		def draw_sprite
			@dirty = false	
		end
	end

	class AbstractRectangleRenderer < AbstractRenderer
		def initialize
			super()
		end

		def paint(x, y, angle)
		end
		
		def set_geometry(width, height)
			@width = width
			@height = height

			@dirty = true
		end
	end

	class AbstractCircleRenderer < AbstractRenderer
		def initialize
			super()
		end

		def paint(x, y)
		end

		def set_geometry(radius)
			@radius = radius	

			@dirty = true
		end
	end

	class AbstractWhellRenderer < AbstractRenderer
		def initialize
			super()
		end

		def paint(x, y, angle)
		end

		def set_geometry(radius)
			@radius = radius	

			@dirty = true
		end
	end
end	
