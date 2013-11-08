define ['core/canvas', 'core/graphics'], (canvas, gfx) ->
	ns = {}

	COUNTER_SIZE = 12
	class ns.DamageCounterSprite extends gfx.StandardGraphic
			constructor: (damage) ->
				@description = "#{damage}"

				super {
					width: @description.length * COUNTER_SIZE
					height: COUNTER_SIZE
				}

			draw: (context) ->
				context.font		= "#{COUNTER_SIZE}px Sans-serif"
				context.fillStyle	= "white"
				context.strokeStyle	= "black"
				context.lineWidth	= 3

				context.strokeText	@description, 0, COUNTER_SIZE - 1
				context.fillText	@description, 0, COUNTER_SIZE - 1

	return ns
