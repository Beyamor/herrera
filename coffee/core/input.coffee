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
		$el.keydown((e) =>
			e.preventDefault() if SPECIAL_BROWSER_KEYS.indexOf(e.which) isnt -1
			@state[e.which] = 'down'
		).keyup((e) =>
			e.preventDefault() if SPECIAL_BROWSER_KEYS.indexOf(e.which) isnt -1
			@state[e.which] = 'up'
		)
}
