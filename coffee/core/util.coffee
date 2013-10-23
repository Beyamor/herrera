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
			any: (coll) -> coll[Math.floor(Math.random() * coll.length)]

		isFunction: (x) ->
			x and typeof(x) is "function"

		thunkWrap: (x) ->
			if @isFunction(x) then x else -> x

		bresenham: ({x: x1, y: y1}, {x: x2, y: y2}) ->
			points = []
			isSteep = Math.abs(y2 - y1) > Math.abs(x2 - x1)
			if isSteep
				[x1, y1] = [y1, x1]
				[x2, y2] = [y2, x2]
			rev = false
			if x1 > x2
				[x1, x2] = [x2, x1]
				[y1, y2] = [y2, y1]
				rev = true
			deltaX = x2 - x1
			deltaY = Math.abs(y2 - y1)
			error = Math.floor(deltaX / 2)
			y = y1
			yStep = null
			if y1 < y2
				yStep = 1
			else
				yStep = -1
			for x in [x1..x2]
				if isSteep
					points.push {x: y, y: x} # yeesh
				else
					points.push {x: x, y: y}
				error -= deltaY
				if error < 0
					y += yStep
					error += deltaX
			points.reverse() if rev
			return points

		# yoink: http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html#The%20C%20Code
		pointInPoly: (point, vertices) ->
			isIn = false

			i = 0
			j = vertices.length - 1
			while i < vertices.length
				ysInconsistent = (vertices[i].y > point.y) isnt (vertices[j].y > point.y)
				xSmaller = (point.x < ((vertices[j].x - vertices[i].x) *
							(point.y - vertices[i].y) /
							(vertices[j].y - vertices[i].y) +
							vertices[i].x))

				if ysInconsistent and xSmaller
					isIn = !isIn

				j = i
				i += 1

			return isIn


			return isIn

		Timer: Timer
	}
