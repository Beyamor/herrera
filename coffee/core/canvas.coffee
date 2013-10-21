define ->
	class Canvas
		constructor: (opts) ->
			@$el = $('<canvas>')

			@el = @$el[0]
			@context = @el.getContext '2d'

			if opts.clearColor
				@$el.css 'background-color', opts.clearColor

			opts.width or= @$el.width()
			opts.height or= @$el.height()

			@setDims opts.width, opts.height

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

	return {
		Canvas: Canvas
	}
