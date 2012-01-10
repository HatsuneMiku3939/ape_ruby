require "ape"
require "timer"
require "sdl"
require "SDLRender"
include APE

class Rotator < Group
	def initialize(display, color_a, color_b)
		super()
		@collide_internal = true

		@ctr = Vector.new(555, 175)
		@rect_composite = RectComposite.new(display, @ctr, color_a, color_b)
		add_composite(@rect_composite)
		
		circle_a_render = SDLCircleRender.new(5, display)
		circle_a = CircleParticle.new(@ctr.x, @ctr.y, 5, circle_a_render)
		circle_a.set_style(color_a, 255, color_b, 255)
		add_particles(circle_a)
		
		rect_a_render = SDLRectangleRender.new(10, 10, display)
		rect_a = RectangleParticle.new(555, 160, 10, 10, rect_a_render, 0, false, 3)
		rect_a.set_style(color_a, 255, color_b, 255)
		add_particles(rect_a)

		connector_a_render = SDLRectangleRender.new(1, 1, display)
		connector_a = SpringConstraint.new(@rect_composite.ra, rect_a, connector_a_render, 1)
		connector_a.set_style(color_b, 255)
		add_constraint(connector_a)

		rect_b_render = SDLRectangleRender.new(10, 10, display)
		rect_b = RectangleParticle.new(555, 190, 10, 10, rect_b_render, 0, false, 3)
		rect_b.set_style(color_a, 255, color_b, 255)
		add_particles(rect_b)

		connector_b_render = SDLRectangleRender.new(1, 1, display)
		connector_b = SpringConstraint.new(@rect_composite.rc, rect_b, connector_a_render, 1)
		connector_b.set_style(color_b, 255)
		add_constraint(connector_b)
	end
	
	def rotate_by_radian(a)
		@rect_composite.rotate_by_radian(a, @ctr)
	end
end

class RectComposite < Composite
	def initialize(display, ctr, color_a, color_b)
		super()
		
		rw = 75
		rh = 18
		rad = 4
		
		cp_a_render = SDLCircleRender.new(rad, display)	
		@cp_a = CircleParticle.new(ctr.x-rw/2, ctr.y-rh/2, rad, cp_a_render, true)

		cp_b_render = SDLCircleRender.new(rad, display)	
		cp_b = CircleParticle.new(ctr.x+rw/2, ctr.y-rh/2, rad, cp_b_render, true)

		cp_c_render = SDLCircleRender.new(rad, display)	
		@cp_c = CircleParticle.new(ctr.x+rw/2, ctr.y+rh/2, rad, cp_c_render, true)	

		cp_d_render = SDLCircleRender.new(rad, display)	
		cp_d = CircleParticle.new(ctr.x-rw/2, ctr.y+rh/2, rad, cp_d_render, true)	

		@cp_a.set_style([0, 0, 0], 0, color_a)
		cp_b.set_style([0, 0, 0], 0, color_a)
		@cp_c.set_style([0, 0, 0], 0, color_a)
		cp_d.set_style([0, 0, 0], 0, color_a)
		
		spr_a_render = SDLRectangleRender.new(1, 1, display)
		spr_a = SpringConstraint.new(@cp_a, cp_b, spr_a_render, 0.5, true, rad * 2)

		spr_b_render = SDLRectangleRender.new(1, 1, display)
		spr_b = SpringConstraint.new(cp_b, @cp_c, spr_b_render, 0.5, true, rad * 2)

		spr_c_render = SDLRectangleRender.new(1, 1, display)
		spr_c = SpringConstraint.new(@cp_c, cp_d, spr_c_render, 0.5, true, rad * 2)

		spr_d_render = SDLRectangleRender.new(1, 1, display)
		spr_d = SpringConstraint.new(cp_d, @cp_a, spr_d_render, 0.5, true, rad * 2)

		spr_a.set_style([0, 0, 0], 0, color_a)
		spr_b.set_style([0, 0, 0], 0, color_a)
		spr_c.set_style([0, 0, 0], 0, color_a)
		spr_d.set_style([0, 0, 0], 0, color_a)
		
		add_particles(@cp_a)
		add_particles(cp_b)
		add_particles(@cp_c)
		add_particles(cp_d)

		add_constraint(spr_a)
		add_constraint(spr_b)
		add_constraint(spr_c)
		add_constraint(spr_d)
	end

	def ra
		return @cp_a	
	end

	def rc
		return @cp_c
	end
end

class Capsule < Group
	def initialize(display, color_c)
		super() 

		capsule_p1_render = SDLCircleRender.new(14, display)	
		capsule_p1 = CircleParticle.new(300, 10, 14, capsule_p1_render, false, 1.3, 0.4)
		capsule_p1.set_style(color_c, 0, color_c, 255)
		add_particles(capsule_p1)

		capsule_p2_render = SDLCircleRender.new(14, display)	
		capsule_p2 = CircleParticle.new(325, 35, 14, capsule_p2_render, false, 1.3, 0.4)
		capsule_p2.set_style(color_c, 0, color_c, 255)
		add_particles(capsule_p2)

		capsule_render = SDLRectangleRender.new(1, 1, display)
		capsule = SpringConstraint.new(capsule_p1, capsule_p2, capsule_render, 1, true, 24)
		capsule.set_style(color_c, 255, color_c, 255)
		add_constraint(capsule)
	end
end

class Surfaces < Group
	def initialize(display, color_a, color_b, color_c, color_d, color_e)
		super() 
		
		floor_render = SDLRectangleRender.new(550, 50, display)
		floor = RectangleParticle.new(340, 327, 550, 50, floor_render, 0, true, 1.0, 0.3, 0)
		floor.set_style(color_d, 255, color_d, 255)
		add_particles(floor)
		
		ceil_render = SDLRectangleRender.new(649, 80, display)
		ceil = RectangleParticle.new(325, -33, 649, 80, ceil_render, 0, true, 1.0, 0.3, 0)
		ceil.set_style(color_d, 255, color_d, 255)
		add_particles(ceil)

		ramp_render = SDLRectangleRender.new(390, 20, display)
		ramp_right = RectangleParticle.new(375, 220, 390, 20, ramp_render, 0.405, true, 1.0, 0.3, 0)
		ramp_right.set_style(color_d, 255, color_d, 255)
		add_particles(ramp_right)

		ramp_left_render = SDLRectangleRender.new(390, 20, display)
		ramp_left = RectangleParticle.new(90, 200, 102, 20, ramp_left_render, -0.7, true, 1.0, 0.3, 0)
		ramp_left.set_style(color_d, 255, color_d, 255)
		add_particles(ramp_left)

		ramp_left2_render = SDLRectangleRender.new(102, 20, display)
		ramp_left2 = RectangleParticle.new(96, 129, 102, 20, ramp_left2_render, -0.7, true, 1.0, 0.3, 0)
		ramp_left2.set_style(color_d, 255, color_d, 255)
		add_particles(ramp_left2)

		ramp_circle_render = SDLCircleRender.new(60, display)	
		ramp_circle = CircleParticle.new(175, 190, 60, ramp_circle_render, true, 1.0, 0.3, 0)
		ramp_circle.set_style(color_d, 255, color_b, 255)
		add_particles(ramp_circle)

		floor_bump_render = SDLCircleRender.new(400, display)	
		floor_bump = CircleParticle.new(600, 660, 400, floor_bump_render, true, 1.0, 0.3, 0)
		floor_bump.set_style(color_d, 255, color_b, 255)
		add_particles(floor_bump)

		bounce_pad_render = SDLRectangleRender.new(32, 60, display)
		bounce_pad = RectangleParticle.new(30, 370, 32, 60, bounce_pad_render, 0, true, 1.0, 0.3, 0)
		bounce_pad.set_style(color_d, 255, [0x99, 0x66, 0x33], 255)
		bounce_pad.elasticity = 4
		add_particles(bounce_pad)

		left_wall_render = SDLRectangleRender.new(30, 500, display)
		left_wall = RectangleParticle.new(1, 99, 30, 500, left_wall_render, 0, true, 1.0, 0.3, 0)
		left_wall.set_style(color_d, 255, color_d, 255)
		add_particles(left_wall)
		
		left_wall_channel_inner_render = SDLRectangleRender.new(20, 150, display)
		left_wall_channel_inner = RectangleParticle.new(54, 300, 20, 150, left_wall_channel_inner_render, 0, true, 1.0, 0.3, 0)
		left_wall_channel_inner.set_style(color_d, 255, color_d, 255)
		add_particles(left_wall_channel_inner)
		
		left_wall_channel_render = SDLRectangleRender.new(20, 94, display)
		left_wall_channel = RectangleParticle.new(54, 122, 20, 94, left_wall_channel_render, 0, true, 1.0, 0.3, 0)
		left_wall_channel.set_style(color_d, 255, color_d, 255)
		add_particles(left_wall_channel)

		left_wall_channel_ang_render = SDLRectangleRender.new(60, 25, display)
		left_wall_channel_ang = RectangleParticle.new(75, 65, 60, 25, left_wall_channel_ang_render, -0.7, true, 1.0, 0.3, 0)
		left_wall_channel_ang.set_style(color_d, 255, color_d, 255)
		add_particles(left_wall_channel_ang)

		top_left_ang_render = SDLRectangleRender.new(64, 40, display)
		top_left_ang = RectangleParticle.new(23, 11, 65, 40, top_left_ang_render, -0.7, true, 1.0, 0.3, 0)
		top_left_ang.set_style(color_d, 255, color_d, 255)
		add_particles(top_left_ang)

		right_wall_render = SDLRectangleRender.new(64, 40, display)
		right_wall = RectangleParticle.new(654, 230, 50, 500, right_wall_render, 0, true, 1.0, 0.3, 0)
		right_wall.set_style(color_d, 255, color_d, 255)
		add_particles(right_wall)

		bridge_start_render = SDLRectangleRender.new(75, 25, display)
		bridge_start = RectangleParticle.new(127, 49, 75, 25, bridge_start_render, 0, true, 1.0, 0.3, 0)
		bridge_start.set_style(color_d, 255, color_d, 255)
		add_particles(bridge_start)

		bridge_end_render = SDLRectangleRender.new(100, 15, display)
		bridge_end = RectangleParticle.new(494, 44, 100, 15, bridge_end_render, 0, true, 1.0, 0.3, 0)
		bridge_end.set_style(color_d, 255, color_d, 255)
		add_particles(bridge_end)
	end
end

class Bridge < Group
	def initialize(display, color_b, color_c, color_d)
		super()

		bx = 170
		by = 40
		bsize = 51.5
		yslope = 2.4
		particle_size = 4

		bridge_PAA_render = SDLCircleRender.new(particle_size, display)	
		bridge_PAA = CircleParticle.new(bx, by, particle_size, bridge_PAA_render, true)
		bridge_PAA.set_style(color_c, 255, color_b, 255)
		add_particles(bridge_PAA)

		bx += bsize
		bx += yslope
		bridge_PA_render = SDLCircleRender.new(particle_size, display)	
		bridge_PA = CircleParticle.new(bx, by, particle_size, bridge_PA_render, false)
		bridge_PA.set_style(color_c, 255, color_b, 255)
		add_particles(bridge_PA)

		bx += bsize
		bx += yslope
		bridge_PB_render = SDLCircleRender.new(particle_size, display)	
		bridge_PB = CircleParticle.new(bx, by, particle_size, bridge_PB_render, false)
		bridge_PB.set_style(color_c, 255, color_b, 255)
		add_particles(bridge_PB)

		bx += bsize
		bx += yslope
		bridge_PC_render = SDLCircleRender.new(particle_size, display)	
		bridge_PC = CircleParticle.new(bx, by, particle_size, bridge_PC_render, false)
		bridge_PC.set_style(color_c, 255, color_b, 255)
		add_particles(bridge_PC)

		bx += bsize
		bx += yslope
		bridge_PD_render = SDLCircleRender.new(particle_size, display)	
		bridge_PD = CircleParticle.new(bx, by, particle_size, bridge_PD_render, false)
		bridge_PD.set_style(color_c, 255, color_b, 255)
		add_particles(bridge_PD)

		bx += bsize
		bx += yslope
		bridge_PDD_render = SDLCircleRender.new(particle_size, display)	
		bridge_PDD = CircleParticle.new(bx, by, particle_size, bridge_PDD_render, true)
		bridge_PDD.set_style(color_c, 255, color_b, 255)
		add_particles(bridge_PDD)

		bridge_conn_A_render = SDLRectangleRender.new(1, 1, display)
		bridge_conn_A = SpringConstraint.new(bridge_PAA, bridge_PA, bridge_conn_A_render, 0.9, true, 3, 0.8, false)
		bridge_conn_A.fixed_end_limit = 0.25
		bridge_conn_A.set_style(color_c, 255, color_b, 255)
		add_constraint(bridge_conn_A)

		bridge_conn_B_render = SDLRectangleRender.new(1, 1, display)
		bridge_conn_B = SpringConstraint.new(bridge_PA, bridge_PB, bridge_conn_B_render, 0.9, true, 3, 0.8, false)
		bridge_conn_B.set_style(color_c, 255, color_b, 255)
		add_constraint(bridge_conn_B)

		bridge_conn_C_render = SDLRectangleRender.new(1, 1, display)
		bridge_conn_C = SpringConstraint.new(bridge_PB, bridge_PC, bridge_conn_C_render, 0.9, true, 3, 0.8, false)
		bridge_conn_C.set_style(color_c, 255, color_b, 255)
		add_constraint(bridge_conn_C)

		bridge_conn_D_render = SDLRectangleRender.new(1, 1, display)
		bridge_conn_D = SpringConstraint.new(bridge_PC, bridge_PD, bridge_conn_D_render, 0.9, true, 3, 0.8, false)
		bridge_conn_D.set_style(color_c, 255, color_b, 255)
		add_constraint(bridge_conn_D)

		bridge_conn_E_render = SDLRectangleRender.new(1, 1, display)
		bridge_conn_E = SpringConstraint.new(bridge_PD, bridge_PDD, bridge_conn_E_render, 0.9, true, 3, 0.8, false)
		bridge_conn_E.fixed_end_limit = 0.25
		bridge_conn_E.set_style(color_c, 255, color_b, 255)
		add_constraint(bridge_conn_E)
	end
end

class SwingDoor < Group
	def initialize(display, color_e)
		super()
		@collide_internal = true

		swing_door_p1_render = SDLCircleRender.new(7, display)	
		swing_door_p1 = CircleParticle.new(555, 44, 7, swing_door_p1_render)
		swing_door_p1.mass = 0.001;
		swing_door_p1.set_style(color_e, 255, color_e, 255)
		add_particles(swing_door_p1);

		swing_door_p2_render = SDLCircleRender.new(7, display)	
		swing_door_p2 = CircleParticle.new(620, 44, 7, swing_door_p2_render, true);
		swing_door_p2.set_style(color_e, 255, color_e, 255)
		add_particles(swing_door_p2)

		swing_door_render = SDLRectangleRender.new(1, 1, display)
		swing_door = SpringConstraint.new(swing_door_p1, swing_door_p2, swing_door_render, 1, true, 13);
		swing_door.set_style(color_e, 255, color_e, 255)
		add_constraint(swing_door)

		swing_door_anchor_render = SDLCircleRender.new(2, display)	
		swing_door_anchor = CircleParticle.new(543, 5, 2, swing_door_anchor_render, true)
		swing_door_anchor.visible = false
		swing_door_anchor.collidable = false
		add_particles(swing_door_anchor)

		swing_door_spring_render = SDLRectangleRender.new(1, 1, display)
		swing_door_spring = SpringConstraint.new(swing_door_p1, swing_door_anchor, swing_door_spring_render, 0.02)
		swing_door_spring.rest_length = 40
		swing_door_spring.visible = false
		add_constraint(swing_door_spring)

		stopper_a_render = SDLCircleRender.new(70, display)	
		stopper_a = CircleParticle.new(550, -60, 70, stopper_a_render, true)
		stopper_a.visible = false
		add_particles(stopper_a)

		stopper_b_render = SDLRectangleRender.new(42, 70, display)
		stopper_b = RectangleParticle.new(650, 130, 42, 70, stopper_b_render, 0, true)
		stopper_b.visible = false
		add_particles(stopper_b)
	end
end

class Car < Group
	def initialize(display, color_c, color_e)
		super()

		wheelA_render = SDLWheelRender.new(14, display)
		@wheelA = WheelParticle.new(140, 10, 14, wheelA_render, false, 2, 0.3, 0, 1)
		@wheelA.set_style(color_c, 255, color_e, 255)
		add_particles(@wheelA)

		wheelB_render = SDLWheelRender.new(14, display)
		@wheelB = WheelParticle.new(200, 10, 14, wheelB_render, false, 2, 0.3, 0, 1)
		@wheelB.set_style(color_c, 255, color_e, 255)
		add_particles(@wheelB)

		conn_render = SDLRectangleRender.new(1, 1, display)
		conn = SpringConstraint.new(@wheelA, @wheelB, conn_render, 0.5, true, 8, 1, false)
		conn.set_style(color_c, 0, color_e, 255)
		add_constraint(conn)
	end

	def speed(s)
		@wheelA.angular_velocity = s
		@wheelB.angular_velocity = s
	end
end

def init
	SDL.init(SDL::INIT_VIDEO | SDL::INIT_AUDIO)
	$display = SDL::set_video_mode($screen_width, $screen_height, $screen_bpp, SDL::HWSURFACE)

	apengine = APEngine.instance
	apengine.init(1/4.0) 

	color_a = [rand(255), rand(255), rand(255)]
	color_b = [rand(255), rand(255), rand(255)]
	color_c = [rand(255), rand(255), rand(255)]
	color_d = [rand(255), rand(255), rand(255)]
	color_e = [rand(255), rand(255), rand(255)]

	surfaces = Surfaces.new($display, color_a, color_b, color_c, color_d, color_e)
	bridge = Bridge.new($display, color_b, color_c, color_d)
	swing_door = SwingDoor.new($display, color_e)
	capsule = Capsule.new($display, color_c)
	rotator = Rotator.new($display, color_b, color_e)

	car = Car.new($display, color_c, color_e)

	apengine.add_group(surfaces)
	apengine.add_group(bridge)
	apengine.add_group(swing_door)
	apengine.add_group(capsule)
	apengine.add_group(car)
	apengine.add_group(rotator)

	car.add_collidable_list([surfaces, bridge, swing_door, capsule, rotator])
	capsule.add_collidable_list([surfaces, bridge, swing_door, rotator])

	apengine.add_force(VectorForce.new(false, 0, 3))

	SDL::Key.enable_key_repeat SDL::Key::DEFAULT_REPEAT_DELAY, SDL::Key::DEFAULT_REPEAT_INTERVAL

	return car, rotator
end

def clean_up
	# do nothing	
end

def message_handler(car)
	quit = true

	while event = SDL::Event.poll
		case event
		when SDL::Event::Quit
			quit = false
		when SDL::Event::KeyDown
			case event.sym
			when SDL::Key::LEFT
				car.speed(-0.2)
			when SDL::Key::RIGHT
				car.speed(+0.2)
			when SDL::Key::UP
				car.speed(0)	
			when SDL::Key::ESCAPE 
				quit = false
			end
		end
	end

	return quit
end

def main	
	car, rotator = init

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
		rotator.rotate_by_radian(0.05)

		apengine.paint
		$display.flip

		flag = message_handler(car)
	end

	clean_up
end

$screen_width = 640
$screen_height = 348
$screen_bpp = 32
$frames_per_second = 60

puts "APE ENGINE 0.50a CREATED"
puts "Original Action Script Version By Alec Cove"
puts "Ruby/SDL port By DMW"

main
