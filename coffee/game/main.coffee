define ['core/app', 'core/input', 'game/play', 'core/debug'], (app, input, play, debug) ->
	debug.loading = false

	app.assets = [
		['player-sprite', 'res/img/player.png']
	]

	input.define
		up: 87
		down: 83
		left: 65
		right: 68

	app.launch
		width: 800
		height: 600
		id: 'game'
		init: ->
			app.scene = new play.PlayScene
