require 'sdl'
include APE

$SDL_COLORKEY = [0, 0xFF, 0xFF]

def get_endian
	big_endian = ([1].pack("N") == [1].pack("L"))

	if big_endian
		rmask = 0xff000000
		gmask = 0x00ff0000
		bmask = 0x0000ff00
		amask = 0x000000ff
	else
		rmask = 0x000000ff
		gmask = 0x0000ff00
		bmask = 0x00ff0000
		amask = 0xff000000
	end

	return rmask, gmask, bmask, amask
end

class SDLRectangleRender < AbstractRectangleRenderer
	def initialize(width, height, display, color_depth = 32)
		super()

		set_geometry(width, height)
		@color_depth = color_depth
		@display = display
	end

	def paint(x, y, angle)
		draw_sprite if @dirty

		SDL::Surface.transform_blit(@image, @display, angle, 1.0, 1.0, @width/2, @height/2, x, y, 0)
	end

	def draw_sprite
		super()
		rmask, gmask, bmask, amask = get_endian
		
		@image = SDL::Surface.new(SDL::HWSURFACE, @width, @height, @color_depth, rmask, gmask, bmask, amask)

		@image = @image.display_format
		color_key = @image.map_rgb(*$SDL_COLORKEY)
		@image.set_color_key(SDL::SRCCOLORKEY, color_key)
		@image.draw_rect(0, 0, @width, @height, color_key, true)

		@image.draw_rect(0, 0, @width, @height, @fill_color, true, @fill_alpha)
		@image.draw_rect(0, 0, @width, @height, @line_color, false, @line_alpha)
	end
end

class SDLCircleRender < AbstractCircleRenderer
	def initialize(radius, display, color_depth = 32)
		super()

		set_geometry(radius)
		@color_depth = color_depth
		@display = display
	end

	def paint(x, y)
		draw_sprite if @dirty
		
		SDL::Surface.transform_blit(@image, @display, 0, 1.0, 1.0, @radius, @radius, x, y, 0)
	end

	def draw_sprite
		super()
		rmask, gmask, bmask, amask = get_endian

		@image = SDL::Surface.new(SDL::HWSURFACE, @radius*2+1, @radius*2+1, @color_depth, rmask, gmask, bmask, amask)

		@image = @image.display_format
		color_key = @image.map_rgb(*$SDL_COLORKEY)
		@image.set_color_key(SDL::SRCCOLORKEY, color_key)
		@image.draw_rect(0, 0, @radius*2+1, @radius*2+1, color_key, true)

		@image.draw_circle(@radius, @radius, @radius, @fill_color, true, false, @fill_alpha)
		@image.draw_circle(@radius, @radius, @radius, @line_color, false, false, @line_alpha)
	end
end

class SDLWheelRender < AbstractWhellRenderer
	def initialize(radius, display, color_depth = 32)
		super()
		
		set_geometry(radius)
		@color_depth = color_depth
		@display = display	
	end

	def paint(x, y, angle)
		draw_sprite if @dirty
		
		SDL::Surface.transform_blit(@image, @display, angle, 1.0, 1.0, @radius, @radius, x, y, 0)	
	end

	def draw_sprite
		super()
		rmask, gmask, bmask, amask = get_endian

		@image = SDL::Surface.new(SDL::HWSURFACE, @radius*2+1, @radius*2+1, @color_depth, rmask, gmask, bmask, amask)

		@image = @image.display_format
		color_key = @image.map_rgb(*$SDL_COLORKEY)
		@image.set_color_key(SDL::SRCCOLORKEY, color_key)
		@image.draw_rect(0, 0, @radius*2+1, @radius*2+1, color_key, true)

		@image.draw_circle(@radius, @radius, @radius, @fill_color, true, false, @fill_alpha)
		@image.draw_circle(@radius, @radius, @radius, @line_color, false, false, @line_alpha)

		@image.draw_line(0, @radius, @radius*2, @radius, @line_color, false)
		@image.draw_line(@radius, 0, @radius, @radius*2, @line_color, false)
	end
end
