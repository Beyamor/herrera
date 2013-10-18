SPECIAL_BROWSER_KEYS = [
	32, # space
	37, # left
	38, # right
	39, # down
	40, # up
]

define {
	state: {}
	mappings: {}

	mouseX: 0
	mouseY: 0

	isDown: (key) ->
		if @mappings[key]?
			return @isDown @mappings[key]
		else
			state = @state[key]
			return state is 'down'

	isUp: (key) ->
		if @mappings[key]?
			return @isUp @mappings[key]
		else
			state = @state[key]
			return (not state) or state is 'up'

	define: (mappings) ->
		for from, to of mappings
			@mappings[from] = to

	watch: ($el) ->
		eventToMouseButton = (e) ->
			switch e.which
				when 1 then 'mouse-left'
				when 2 then 'mouse-middle'
				when 3 then 'mouse-right'

		$el.keydown (e) =>
			e.preventDefault() if SPECIAL_BROWSER_KEYS.indexOf(e.which) isnt -1
			@state[e.which] = 'down'

		.keyup (e) =>
			e.preventDefault() if SPECIAL_BROWSER_KEYS.indexOf(e.which) isnt -1
			@state[e.which] = 'up'

		.mousemove (e) =>
			@mouseX = e.pageX - $el.parent().offset().left
			@mouseY = e.pageY - $el.parent().offset().top

		.mousedown (e) =>
			@state[eventToMouseButton(e)] = 'down'

		.mouseup (e) =>
			@state[eventToMouseButton(e)] = 'up'
}
