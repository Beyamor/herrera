SPECIAL_BROWSER_KEYS = [
	32, # space
	37, # left
	38, # right
	39, # down
	40, # up
]

define {
	currentState: {}
	prevState: {}
	events: []
	mappings: {}

	mouseX: 0
	mouseY: 0

	isDown: (key, state) ->
		state or= @currentState
		if @mappings[key]?
			return @isDown @mappings[key], state
		else
			state = state[key]
			return state is 'down'

	isUp: (key, state) ->
		state or= @currentState
		if @mappings[key]?
			return @isUp @mappings[key], state
		else
			state = state[key]
			return (not state) or state is 'up'

	pressed: (key) ->
		@isDown(key, @currentState) and @isUp(key, @prevState)

	released: (key) ->
		@isUp(key, @currentState) and @isDown(key, @prevState)

	define: (mappings) ->
		for from, to of mappings
			@mappings[from] = to

	update: ->
		# first, copy the state over
		@prevState = {}
		for k, v of @currentState
			@prevState[k] = v

		# then, update the current state
		for [k, v] in @events
			@currentState[k] = v

		# and finally, clear the events
		@events = []


	watch: ($el) ->
		eventToMouseButton = (e) ->
			switch e.which
				when 1 then 'mouse-left'
				when 2 then 'mouse-middle'
				when 3 then 'mouse-right'

		$el.keydown (e) =>
			e.preventDefault() if SPECIAL_BROWSER_KEYS.indexOf(e.which) isnt -1
			@events.push [e.which, 'down']

		.keyup (e) =>
			e.preventDefault() if SPECIAL_BROWSER_KEYS.indexOf(e.which) isnt -1
			@events.push [e.which, 'up']

		.mousemove (e) =>
			@mouseX = e.pageX - $el.parent().offset().left
			@mouseY = e.pageY - $el.parent().offset().top

		.mousedown (e) =>
			@events.push [eventToMouseButton(e), 'down']

		.mouseup (e) =>
			@events.push [eventToMouseButton(e), 'up']

		$el.attr 'oncontextmenu', 'return false;'
}
