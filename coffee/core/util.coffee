define ->
	Function::define = (prop, desc) ->
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

	return {
		sign: (x) -> (x > 0) - (x < 0)

		aabbsIntersect: (a, b) ->
			not (a.right < b.left or
				a.left > b.right or
				a.bottom < b.top or
				a.top > b.bottom)

		array2d: array2d
	}
