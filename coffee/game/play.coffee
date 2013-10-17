define ['core/app', 'core/scenes', 'core/entities', 'core/graphics'],
	(app, scenes, entities, gfx) ->
		class Player extends entities.Entity
			constructor: (x, y) ->
				super x, y, new gfx.Rect 100, 100, 'red'

			update: ->
				@pos.x += app.elapsed * 100

		class PlayScene extends scenes.Scene
			constructor: ->
				super()
				@add new Player 50, 50

		return {
			PlayScene: PlayScene
		}
