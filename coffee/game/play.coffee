define ['core/app', 'core/scenes', 'game/entities', 'core/cameras', 'game/levels'],
	(app, scenes, entities, cameras, levels) ->
		ns = {}

		Player = entities.Player

		class ns.PlayScene extends scenes.Scene
			constructor: ->
				super()
				player = new Player app.width / 2, app.height / 2
				@add player

				room = new levels.Room
				for e in room.realize()
					@add e

				@camera = new cameras.EntityFollower player, @camera

		return ns
