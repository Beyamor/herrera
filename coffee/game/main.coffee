define ['core/app', 'core/entities', 'core/graphics', 'core/input'], (app, ents, gfx, input) ->
	app.init {
		width: 800
		height: 600
		id: 'game'
	}

	ent = new ents.Entity(50, 50, new gfx.Rect(100, 100, 'red'))
	ent.render()

	input.define
		up: 87
		down: 83
		left: 65
		right: 68
