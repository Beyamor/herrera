define ->
	class Canvas
		constructor: (opts) ->
			@$el = $('<canvas>')

			@el = @$el[0]
			@context = @el.getContext '2d'

			if opts.backgroundColor
				@$el.css 'background-color', opts.backgroundColor

			opts.width or= @$el.width()
			opts.height or= @$el.height()

			@setDims opts.width, opts.height

			if opts.class?
				@$el.attr "class", opts.class

		clear: ->
			@context.clearRect 0, 0, @$el.width(), @$el.height()
			return this

		setDims: (@width, @height) ->
			@$el.width width
			@$el.height height
			@context.canvas.width = width
			@context.canvas.height = height

		renderTo: (target, x, y) ->
			x or= 0
			y or= 0
			target.context.drawImage @el, x, y

		drawPixel: (x, y, [r, g, b, a]) ->
			@pixel or= @context.createImageData 1, 1

			data = @pixel.data
			data[0] = r
			data[1] = g
			data[2] = b
			data[3] = a or 255

			@context.putImageData @pixel, x, y

	return {
		Canvas: Canvas
	}
