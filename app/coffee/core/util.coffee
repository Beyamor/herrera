define ['core/app'], (app) ->
	Function::accessors = (definitions) ->
		for prop, desc of definitions
			Object.defineProperty this.prototype, prop, desc

	Array::remove = (val) ->
		index = this.indexOf val
		return unless index > -1
		@splice index, 1

	Array::contains = (val) ->
		this.indexOf(val) isnt -1

	array2d = (width, height, constructor) ->
		a = []
		for i in [0...width]
			a.push []
			for j in [0...height]
				a[i].push if constructor then constructor(i, j) else null

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

	copy = (obj)->
		if not obj? or typeof obj isnt 'object'
			return obj

		if obj instanceof Date
			return new Date(obj.getTime())

		if obj instanceof RegExp
			flags = ''
			flags += 'g' if obj.global?
			flags += 'i' if obj.ignoreCase?
			flags += 'm' if obj.multiline?
			flags += 'y' if obj.sticky?
			return new RegExp(obj.source, flags)

		newInstance = new obj.constructor()

		for key of obj
			newInstance[key] = copy obj[key]

		return newInstance

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
			inRange: (args...) ->
				if args.length is 2
					[min, max] = args
					return min + Math.random() * (max - min)
				else if args.length is 1
					[max] = args
					return @inRange 0, max
				else throw new Error "Bad arglength #{args.length}"

			intInRange: (args...) ->
				if args.length is 2
					[min, max] = args
					return Math.floor(@inRange min, max)
				else if args.length is 1
					[max] = args
					return @intInRange 0, max
				else throw new Error "Bad arglength #{args.length}"

			angle: -> @inRange 0, 2 * Math.PI
			any: (coll) -> coll[Math.floor(Math.random() * coll.length)]
			coinFlip: -> Math.random() < 0.5

		isFunction: (x) ->
			x and typeof(x) is "function"

		thunkWrap: (x) ->
			if @isFunction(x) then x else -> x

		copy: copy

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

		DIRECTIONS: ["north", "east", "south", "west"]

		oppositeDirection: (direction) ->
			@DIRECTIONS[(@DIRECTIONS.indexOf(direction) + 2) % @DIRECTIONS.length]

		deltaToDirection: (dx, dy) ->
			if dx < 0 and dy is 0
				"west"
			else if dx > 0 and dy is 0
				"east"
			else if dy < 0 and dx is 0
				"north"
			else if dy > 0 and dx is 0
				"south"
			else
				throw new Error "Unconvertible delta #{dx}, #{dy}"

		directionToDelta: (direction) ->
			switch direction
				when "north" then [0, -1]
				when "south" then [0, 1]
				when "east" then [1, 0]
				when "west" then [-1, 0]
				else throw new Error "Unknown direction #{direction}"

		realizeArg: (arg) ->
			if Array.isArray arg
				arg[0] + Math.random() * (arg[1] - arg[0])
			else
				arg
	}
