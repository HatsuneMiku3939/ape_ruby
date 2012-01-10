module APE
	class AbstractItem
		include EventDispatcher
		attr_reader :line_color, :line_alpha, :fill_color, :fill_alpha
		attr_accessor :visible, :always_repaint, :solid
		
		def initialize
			@solid = true
			@visible = true
			@always_repaint = true
			@ape = APEngine.instance

			setup_listeners
		end
		
		def init        
		end
		
		def paint
		end
		
		def cleanup
		end
		
		def set_style(line_color = [0, 0, 0], line_alpha = 255, fill_color = [255, 255, 255], fill_alpha = 255)
			set_line(line_color, line_alpha)
			set_fill(fill_color, fill_alpha)
		end
		
		def set_line(color = [0, 0, 0], alpha = 255)
			@line_color = color
			@line_alpha = alpha
		end
		
		def set_fill(color = [255, 255, 255], alpha = 255)
			@fill_color = color
			@fill_alpha = alpha
		end

		def update(event, arg)
		end
	end
end
