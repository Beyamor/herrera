define ['core/app', 'core/input', 'game/play'], (app, input, play) ->
	app.init {
		width: 800
		height: 600
		id: 'game'
	}

	input.define
		up: 87
		down: 83
		left: 65
		right: 68

	app.scene = new play.PlayScene
