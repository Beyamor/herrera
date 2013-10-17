define ['core/app', 'core/entities', 'core/graphics'], (app, ents, gfx) ->
	app.init {
		width: 800
		height: 600
		id: 'game'
	}

	ent = new ents.Entity(50, 50, new gfx.Rect(100, 100, 'red'))
	ent.render()
