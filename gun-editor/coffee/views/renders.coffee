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
					.append(ui.button "Gun", => @renderGun())
					.append(ui.button "Selected variant", => @renderSelectedVariant())

			@canvas = new canvas.Canvas width: CANVAS_WIDTH, height: CANVAS_HEIGHT
			@$el.append @canvas.$el

		realizationSprite: (realization) ->
			sprite		= new canvas.Canvas width: SPRITE_WIDTH, height: SPRITE_HEIGHT
			context		= sprite.context
			context.save()
			context.translate SPRITE_WIDTH/2, SPRITE_HEIGHT/2

			context.beginPath()
			for piece in realization.pieces
				lastVertex = piece.vertices[piece.vertices.length - 1]
				context.moveTo lastVertex.x, lastVertex.y

				for vertex in piece.vertices
					context.lineTo vertex.x, vertex.y

				context.fillStyle = "red"
				context.fill()

				for [v1, v2] in piece.visibleEdges
					context.beginPath()
					context.moveTo v1.x, v1.y
					context.lineTo v2.x, v2.y

					context.strokeStyle = "black"
					context.stroke()

			context.restore()
			return sprite

		renderSelectedVariant: ->
			@canvas.clear()
			selectedVariant = @model.get 'selectedVariant'
			return unless selectedVariant

			context = @canvas.context

			for i in [0...THINGS_PER_ROW]
				for j in [0..THINGS_PER_COLUMN]
					x = i * (SPRITE_WIDTH + X_MARGIN)
					y = j * (SPRITE_HEIGHT + Y_MARGIN)
					sprite = @realizationSprite selectedVariant.realize()
					sprite.renderTo @canvas, x, y

		renderGun: ->
			@canvas.clear()

			for i in [0...THINGS_PER_ROW]
				for j in [0...THINGS_PER_COLUMN]
					x = i * (SPRITE_WIDTH + X_MARGIN)
					y = j * (SPRITE_HEIGHT + Y_MARGIN)
					for realization in @model.realize()
						sprite = @realizationSprite realization
						sprite.renderTo @canvas, x, y
	return ns
