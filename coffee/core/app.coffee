define ['core/canvas'], (cnvs) ->
	
	return {
		init: (opts) ->
			@width = opts.width
			@height = opts.height
			@canvas = new cnvs.Canvas {
				width: @width
				height: @height
				id: opts.id
				clearColor: (opts.clearColor or 'white')
			}
	}
