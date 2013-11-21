define ['core/app', 'core/scenes', 'core/canvas',
	'core/cameras', 'game/levels', 'game/levels/layouts',
	'game/levels/reification', 'game/play/hud', 'core/util'],
	(app, scenes, canvas, cameras, levels, levelLayouts, levelReification, hud, util) ->
		ns = {}

		class BuildingScreen
			constructor: ->
				@el = $('<div class="load-screen">')
				app.canvas.$el.after @el

				@elipseCount = 0
				@updateText()

				@timer = new util.Timer
						period: 0.2
						loops: true
						callback: =>
							@elipseCount = (@elipseCount + 1) % 4
							@updateText()
						start: true

			updateText: ->
				@el.text "Building#{Array(@elipseCount+1).join(".")}"

			update: ->
				@timer.update()

			remove: ->
				@el.remove()

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

				@buildingScreen = new BuildingScreen

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

				@buildingScreen.remove()
				@buildingScreen = null

			update: ->
				super()
				@buildingScreen.update() if @buildingScreen?

			end: ->
				super()
				@hud.remove()

			render: ->
				super()
				return unless @hudElements?
				element.render() for element in @hudElements

		return ns
