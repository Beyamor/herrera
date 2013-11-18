define ['core/canvas'], (canvas) ->
	ns = {}

	class ns.AmmoDisplay
		constructor: (@hud, @player) ->
			@canvas = new canvas.Canvas
				width: 100
				height: 20
				class: "ammo-display"

			context = @canvas.context
			context.fillStyle = context.strokeStyle = "#FACB0F"
			context.lineWidth = 4

			@hud.append @canvas.$el

		render: ->
			return unless @player.inventory.gun
			gun = @player.inventory.gun

			@canvas.clear()
			context = @canvas.context

			width = Math.floor (100 / gun.maxCapacity)
			for i in [0...Math.floor(gun.capacity)]
				context.beginPath()
				context.rect 100 - (i + 1) * width, 0, width, 20
				context.fillStyle = "#FACB0F"
				context.fill()
				context.strokeStyle = "black"
				context.stroke()

	return ns
