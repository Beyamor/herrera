define ['core/app', 'core/scenes', 'core/canvas', 'game/entities', 'core/cameras', 'game/levels', 'game/guns'],
	(app, scenes, canvas, entities, cameras, levels, guns) ->
		ns = {}

		Player = entities.Player

		class ns.PlayScene extends scenes.Scene
			constructor: ->
				super()

				level	= new levels.Level
				reifier	= new levels.Reifier
				for e in reifier.reify(level)
					@add e

				player = reifier.player

				@camera = new cameras.EntityFollower player, @camera

				@hud = new canvas.Canvas {
					width: app.width
					height: app.height
				}

				@hudElements = []
				@hudElements.push new guns.AmmoDisplay(@hud, player)

			render: ->
				super()
				@hud.clear()
				hudElement.render() for hudElement in @hudElements
				@hud.renderTo app.canvas

		return ns
