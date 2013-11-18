define ['core/app', 'core/scenes', 'core/canvas',
	'core/cameras', 'game/levels',
	'game/levels/reification', 'game/play/hud'],
	(app, scenes, canvas, cameras, levels, levelReification, hud) ->
		ns = {}

		class ns.PlayScene extends scenes.Scene
			constructor: ->
				super()

				level	= new levels.Level
				reifier	= new levelReification.Reifier
				for e in reifier.reify(level)
					@add e

				player = reifier.player

				@camera = new cameras.EntityFollower player, @camera

				@hud = $('<div class="hud">')

				@hudElements = []
				@hudElements.push new hud.AmmoDisplay(@hud, player)

				@windows = []

			begin: ->
				app.canvas.$el.after @hud

			end: ->
				@hud.remove()

			update: ->
				super() unless @windows.length > 0
				window.update() for window in @windows when window.update?

			render: ->
				super()
				element.render() for element in @hudElements

			addWindow: (window) ->
				app.container.append window.$el
				@windows.push window
				window.scene = this

			removeWindow: (window) ->
				window.$el.remove()
				@windows.remove window

		return ns
