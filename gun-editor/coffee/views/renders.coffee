define ['core/canvas', 'core/util', 'editor/ui'], (canvas, util, ui) ->
	ns = {}

	SPRITE_WIDTH		= 32
	SPRITE_HEIGHT		= 32
	CANVAS_WIDTH		= 600
	CANVAS_HEIGHT		= 200
	THINGS_PER_ROW		= 16
	THINGS_PER_COLUMN	= 5
	X_MARGIN		= (CANVAS_WIDTH - SPRITE_WIDTH * THINGS_PER_ROW) / (THINGS_PER_ROW - 1)
	Y_MARGIN		= (CANVAS_HEIGHT - SPRITE_HEIGHT * THINGS_PER_COLUMN) / (THINGS_PER_COLUMN - 1)

	ns.Renderer = Backbone.View.extend
		el: "#renders"

		initialize: ->
			@$el.append $('<div>')
					.append ui.button "Selected variant", => @renderSelectedVariant()

			@canvas = new canvas.Canvas width: CANVAS_WIDTH, height: CANVAS_HEIGHT
			@$el.append @canvas.$el

		renderSelectedVariant: ->
			selectedVariant = @model.get 'selectedVariant'
			return unless selectedVariant

			context = @canvas.context

			for i in [0...THINGS_PER_ROW]
				for j in [0..THINGS_PER_COLUMN]
					context.beginPath()
					context.rect i * (SPRITE_WIDTH + X_MARGIN), j * (SPRITE_HEIGHT + Y_MARGIN), 32, 32
					context.fillStyle = "black"
					context.fill()

	return ns
