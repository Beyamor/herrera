define ['core/app'], (app) ->
	Function::accessors = (definitions) ->
		for prop, desc of definitions
			Object.defineProperty this.prototype, prop, desc

	Array::remove = (val) ->
		index = this.indexOf val
		return unless index > -1
		@splice index, 1

	array2d = (width, height, constructor) ->
		a = []
		for i in [0...width]
			a.push []
			for j in [0...height]
				a[i].push if constructor then constructor() else null

		a.each = (f) ->
			for i in [0...a.length]
				for j in [0...a[i].length]
					f i, j, a[i][j]
		return a

	class Timer
		constructor: (args) ->
			@period		= args.period
			@callback	= args.callback
			@loops		= args.loops
			@elapsed	= 0

		restart: ->
			@elapsed	= 0
			@running	= true
			return this

		update: ->
			return unless @running

			@elapsed += app.elapsed
			
			if @loops
				while @elapsed >= @period
					@elapsed -= @period
					@callback()

			else
				if @elapsed >= @period
					@callback()

	return {
		sign: (x) -> (x > 0) - (x < 0)

		aabbsIntersect: (a, b) ->
			not (a.right < b.left or
				a.left > b.right or
				a.bottom < b.top or
				a.top > b.bottom)

		array2d: array2d

		directionFrom: (a, b) ->
			Math.atan2 (b.y-a.y), (b.x-a.x)

		distanceBetween: (a, b) ->
			dx = b.x - a.x
			dy = b.y - a.y
			return Math.sqrt dx*dx + dy*dy

		random:
			inRange: (min, max) -> min + Math.random() * (max - min)
			intInRange: (min, max) -> Math.floor(@inRange min, max)
			angle: -> @inRange 0, 2 * Math.PI

		isFunction: (x) ->
			x and typeof(x) is "function"

		thunkWrap: (x) ->
			if @isFunction(x) then x else -> x

		Timer: Timer
	}
