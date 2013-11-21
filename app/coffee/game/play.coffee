define ['core/app', 'core/scenes', 'core/canvas',
	'core/cameras', 'game/levels', 'game/levels/layouts',
	'game/levels/reification', 'game/play/hud'],
	(app, scenes, canvas, cameras, levels, levelLayouts, levelReification, hud) ->
		ns = {}

		class ns.PlayScene extends scenes.Scene
			constructor: ->
				super()

				worker = new Worker 'js/game/levels/build-script.js'
				worker.onerror = (message) ->
					console.log message
				worker.onmessage = (event) ->
					console.log event.data

				level	= levels.construct levelLayouts.create()
				reifier	= new levelReification.Reifier
				for e in reifier.reify(level)
					@add e

				player = reifier.player

				@camera = new cameras.EntityFollower player, @camera

				@hud = $('<div class="hud">')

				@hudElements = []
				@hudElements.push new hud.AmmoDisplay(@hud, player)

			begin: ->
				super()
				app.canvas.$el.after @hud

			end: ->
				super()
				@hud.remove()

			render: ->
				super()
				element.render() for element in @hudElements

		return ns
