module APE
	module EventDispatcher
		def setup_listeners
			@listeners = Hash.new([])
			@change = false
		end

		def register_listener(listener, event)
			@listeners[event] << listener
		end

		def remove_listener(listener, event)
			@listeners[event].delete listener
		end

		def remove_listeners(event)
			@listeners[event] = []
		end

		def count_listeners(event)
			@listeners[event].size
		end

		def changed?
			@change
		end

		protected
		def notify(event, arg)
			return if not @change
			if @listeners[event]
				callback = ("update_at_" + event.to_s).to_sym
				@listeners[event].each do |listener|
					if listener.respond_to? callback
						listener.send callback, arg
					elsif listener.respond_to? :update
						listener.update event, arg
					end
				end
			end
			@change = false
			return nil	
		end

		def changed
			@change = true
		end
	end	

	class Event
	end

	class BreakEvent < Event
		ANGULAR = :break_event_angular

		def initialize(diff)
			@diff = diff
		end
	end

	class CollisionEvent < Event
		COLLIDE = :collision_event_collide
		FIRST_COLLIDE = :collision_event_first_collide
		
		def initialize(bubbles = false, cancelable = false, colliding_item = nil)
			@bubbles = bubbles
			@cancelable = cancelable
			@colliding_item = @colliding_item
		end

		def colliding_item
			return @colliding_item.parent if @colliding_item.kind_of?(SpringConstraintParticle)	
			return @colliding_item
		end
	end
end
