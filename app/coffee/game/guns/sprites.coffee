define ['core/canvas', 'core/util'], (canvas, util) ->
	ns = {}

	SPRITE_WIDTH		= 32
	SPRITE_HEIGHT		= 32

	random = util.random

	class ns.GunSprite
		constructor: ({parts: parts, metal: metalColor, paint: paintColor}) ->
			@canvas		= new canvas.Canvas width: SPRITE_WIDTH, height: SPRITE_HEIGHT
			context		= @canvas.context

			context.save()
			context.translate SPRITE_WIDTH/2, SPRITE_HEIGHT/2

			for part in parts
				for piece in part.pieces
					lastVertex = piece.vertices[piece.vertices.length - 1]

					context.beginPath()
					context.moveTo lastVertex.x, lastVertex.y

					for vertex in piece.vertices
						context.lineTo vertex.x, vertex.y

					context.fillStyle = (if piece.painted then paintColor else metalColor)
					context.fill()

					for [v1, v2] in piece.visibleEdges
						context.beginPath()
						context.moveTo v1.x, v1.y
						context.lineTo v2.x, v2.y

						context.strokeStyle = "black"
						context.stroke()

			context.restore()

		render: (target, point, camera) ->
			x = point.x - SPRITE_WIDTH / 2 - camera.x
			y = point.y - SPRITE_HEIGHT / 2 - camera.y

			target.context.drawImage @canvas.el, x, y


	return ns
