define ['core/app', 'core/scenes', 'game/entities', 'core/cameras', 'game/levels'],
	(app, scenes, entities, cameras, levels) ->
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

		return ns
