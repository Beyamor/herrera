define ['core/app', 'core/input', 'game/play', 'core/debug'], (app, input, play, debug) ->
	debug.config
		enabled: true
		types:
			load: false
			fps: true
			hitboxes: false

	app.assets = [
		['player-sprite', 'res/img/player.png'],
		['shot-sprite', 'res/img/shot.png'],
		['wall-sprite', 'res/img/wall.png']
		['shot-spark-sprite', 'res/img/shot-spark.png']
	]

	input.define
		up: 87
		down: 83
		left: 65
		right: 68
		shoot: 'mouse-left'

	app.launch
		width: 800
		height: 600
		id: 'game'
		clearColor: 'black'
		init: ->
			app.scene = new play.PlayScene
