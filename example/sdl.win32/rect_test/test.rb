require "sdl"
require "timer"
require "ape"
require "SDLRender"

include APE

class TestSurface < Group
	def initialize(display)
		super

		bottom_render = SDLRectangleRender.new(640, 50, display)
		@bottom = RectangleParticle.new(320, 327, 640, 50, bottom_render, 0, true, 1, 0.7)
		@bottom.set_style([rand(255), rand(255), rand(255)], 255, [rand(255), rand(255), rand(255)], 255)
		add_particles(@bottom)

		right_render = SDLRectangleRender.new(50, 384, display)
		@right = RectangleParticle.new(615, 192, 50, 384, right_render, 0, true)
		@right.set_style([rand(255), rand(255), rand(255)], 255, [rand(255), rand(255), rand(255)], 255)
		add_particles(@right)
		
		left_render = SDLRectangleRender.new(50, 384, display)
		@left = RectangleParticle.new(25, 192, 50, 384, left_render, 0, true)
		@left.set_style([rand(255), rand(255), rand(255)], 255, [rand(255), rand(255), rand(255)], 255)
		add_particles(@left)

		top_render = SDLRectangleRender.new(640, 50, display)
		@top = RectangleParticle.new(320, 25, 640, 50, top_render, 0, true)
		@top.set_style([rand(255), rand(255), rand(255)], 255, [rand(255), rand(255), rand(255)], 255)
		add_particles(@top)
	end
end

class TestRect < Group
	def initialize(display, x, y)
		super()

		rect_render = SDLRectangleRender.new(20, 20, display)
		@rect = RectangleParticle.new(x, y, 20, 20, rect_render, 0, false, 3, 0.2, 0.1)
		@rect.set_style([rand(255), rand(255), rand(255)], 255, [rand(255), rand(255), rand(255)], 255)
		add_particles(@rect)		
	end
end

def init
	SDL.init(SDL::INIT_VIDEO | SDL::INIT_AUDIO)
	$display = SDL::set_video_mode($screen_width, $screen_height, $screen_bpp, SDL::HWSURFACE)

	apengine = APEngine.instance
	apengine.init(1/4.0) 

	surface = TestSurface.new($display)
	box1 = TestRect.new($display, 174, 200)

	box1.add_collidable_list([surface])

	apengine.add_group(surface)
	apengine.add_group(box1)

	apengine.add_force(VectorForce.new(false, 0, 10))

	SDL::Key.enable_key_repeat SDL::Key::DEFAULT_REPEAT_DELAY, SDL::Key::DEFAULT_REPEAT_INTERVAL
end

def clean_up
	# do nothing	
end

def message_handler
	quit = true

	while event = SDL::Event.poll
		case event
		when SDL::Event::Quit
			quit = false
		when SDL::Event::KeyDown
			case event.sym
			when SDL::Key::ESCAPE 
				quit = false
			end
		end
	end

	return quit
end

def main
	init

	flag = true
	fps = Timer.new
	apengine = APEngine.instance

	while flag

		if fps.get_ticks < 1000 / $frames_per_second
			SDL.delay((100 / $frames_per_second) - fps.get_ticks)
		end

		# draw
		$display.draw_rect(0, 0, $screen_width, $screen_height, [0, 0, 0], true)
		apengine.step
		apengine.paint
		$display.flip

		flag = message_handler
	end

	clean_up
end

$screen_width = 640
$screen_height = 348
$screen_bpp = 32
$frames_per_second = 30

puts "APE ENGINE 0.45a CREATED"
puts "Original Action Script Version By Alec Cove"
puts "Ruby/SDL port By DMW"

main
