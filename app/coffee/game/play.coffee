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
				worker.onmessage = (event) =>
					@levelBuilt(event.data)

				layout = levelLayouts.create()
				worker.postMessage layout

			levelBuilt: (level) ->
				reifier	= new levelReification.Reifier
				for e in reifier.reify(level)
					@add e

				player = reifier.player

				@camera = new cameras.EntityFollower player, @camera

				@hud = $('<div class="hud">')
				app.canvas.$el.after @hud

				@hudElements = []
				@hudElements.push new hud.AmmoDisplay(@hud, player)

			end: ->
				super()
				@hud.remove()

			render: ->
				super()
				return unless @hudElements?
				element.render() for element in @hudElements

		return ns
