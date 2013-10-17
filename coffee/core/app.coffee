define ['core/canvas', 'core/input'], (cnvs, input) ->

	return {
		loop: ->
			newTime = new Date
			@elapsed =  (newTime - @previousTime) * 0.001

			for entity in @entities
				entity.update()

			@canvas.clear()
			for entity in @entities
				entity.render()

			@previousTime = newTime

		init: (opts) ->
			@width = opts.width
			@height = opts.height

			fps = (opts.fps or 30)

			@canvas = new cnvs.Canvas {
				width: @width
				height: @height
				id: opts.id
				clearColor: (opts.clearColor or 'white')
			}
			@canvas.$el.attr('tabindex', 0).focus()

			input.watch @canvas.$el

			# temporary
			@entities = []

			# there's better ways to do this (request anim)
			# but for now, who cares
			@previousTime = new Date
			setInterval =>
				@loop()
			, 1000 / fps
	}
