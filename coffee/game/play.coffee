define ['core/app', 'core/scenes', 'core/canvas', 'game/entities', 'core/cameras', 'game/levels', 'game/guns'],
	(app, scenes, canvas, entities, cameras, levels, guns) ->
		ns = {}

		Player = entities.Player

		class ns.PlayScene extends scenes.Scene
			constructor: ->
				super()
				player = new Player 100, 100
				@add player

				level = new levels.Level
				for e in level.realize()
					@add e

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
