define ['core/app', 'core/input', 'game/play', 'core/debug'], (app, input, play, debug) ->
	debug.config
		enabled: true
		types:
			load: false
			fps: true
			hitboxes: false
			passThuWalls: false
			colorFloors: false

	app.assets = [
		['player-sprite', 'res/img/player.png']
		['shot-sprite', 'res/img/shot.png']
		['wall-sprite', 'res/img/wall.png']
		['shot-spark-sprite', 'res/img/shot-spark.png']
		['shot-smoke-sprite', 'res/img/shot-smoke.png']
		['silverfish-sprite', 'res/img/silverfish.png']
		['gun-sprite', 'res/img/gun.png']
		['barrel-sprite', 'res/img/barrel.png']
		['floor-sprite', 'res/img/floor.png']
		['portal-sprite', 'res/img/portal.png']
	]

	app.templates = [
		['inventory-window', 'templates/inventory/window.html']
		['inventory-item', 'templates/inventory/item.html']
	]

	input.define
		walkUp: 87
		walkDown: 83
		walkLeft: 65
		walkRight: 68
		aimUp: 38
		aimDown: 40
		aimLeft: 37
		aimRight: 39
		grab: 69
		close: 27
		inventory: 73

	app.launch
		width: 800
		height: 600
		id: 'game'
		backgroundColor: 'black'
		init: ->
			app.scene = new play.PlayScene
