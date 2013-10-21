define ['core/app', 'core/scenes', 'game/entities', 'core/cameras', 'game/levels', 'game/guns'],
	(app, scenes, entities, cameras, levels, guns) ->
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

				@ammoDisplay = new guns.AmmoDisplay player.gun

			render: ->
				super()
				@ammoDisplay.render app.canvas

		return ns
