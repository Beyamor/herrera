define ->
	Function::define = (prop, desc) ->
		Object.defineProperty this.prototype, prop, desc

	return {
		sign: (x) -> (x > 0) - (x < 0)
	}
