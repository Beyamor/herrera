define ->
	Function::define = (prop, desc) ->
		Object.defineProperty this.prototype, prop, desc

	return {
		sign: (x) -> (x > 0) - (x < 0)

		aabbsIntersect: (a, b) ->
			not (a.right < b.left or
				a.left > b.right or
				a.bottom < b.top or
				a.top > b.bottom)

	}
