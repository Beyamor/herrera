define ['core/canvas', 'core/input'], (cnvs, input) ->

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
			@canvas.$el.attr('tabindex', 0).focus()

			input.watch @canvas.$el
	}
