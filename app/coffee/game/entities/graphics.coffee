define ['core/canvas'], (canvas) ->
	ns = {}

	COUNTER_SIZE = 12
	class ns.DamageCounterSprite
			constructor: (damage) ->
				description = "#{damage}"

				@canvas = new canvas.Canvas width: description.length * COUNTER_SIZE, height: COUNTER_SIZE

				context			= @canvas.context
				context.font		= "#{COUNTER_SIZE}px Sans-serif"
				context.fillStyle	= "white"
				context.strokeStyle	= "black"
				context.lineWidth	= 3

				context.strokeText	description, 0, COUNTER_SIZE - 1
				context.fillText	description, 0, COUNTER_SIZE - 1

			render: (target, point, camera) ->
				x = point.x - camera.x
				y = point.y - camera.y

				target.context.drawImage @canvas.el, x, y

	return ns
