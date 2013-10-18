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
			e.preventDefault()
			@state[e.which] = 'down'
		).keyup((e) =>
			e.preventDefault()
			@state[e.which] = 'up'
		)
}
