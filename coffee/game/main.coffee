define ['core/app', 'core/input', 'game/play', 'core/debug'], (app, input, play, debug) ->
	debug.config
		enabled: true
		types:
			load: false
			fps: true
			hitboxes: false

	app.assets = [
		['player-sprite', 'res/img/player.png']
		['shot-sprite', 'res/img/shot.png']
		['wall-sprite', 'res/img/wall.png']
		['shot-spark-sprite', 'res/img/shot-spark.png']
		['shot-smoke-sprite', 'res/img/shot-smoke.png']
		['silverfish-sprite', 'res/img/silverfish.png']
		['gun-sprite', 'res/img/gun.png']
	]

	input.define
		up: 87
		down: 83
		left: 65
		right: 68
		shoot: 'mouse-left'
		grab: 69

	app.launch
		width: 800
		height: 600
		id: 'game'
		clearColor: 'black'
		init: ->
			app.scene = new play.PlayScene
