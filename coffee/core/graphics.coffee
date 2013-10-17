define ->
	class Canvas
		constructor: (opts) ->
			if opts.id?
				@$el = $("##{opts.id}")
			else if opts.$el?
				@$el = opts.$el
			else
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

		setDims: (width, height) ->
			@$el.width width
			@$el.height height
			@context.canvas.width = width
			@context.canvas.height = height

	return {
		Canvas: Canvas
	}
