define ['core/app', 'core/scenes', 'core/entities', 'core/graphics',
	'core/input'],
	(app, scenes, entities, gfx, input) ->
		class Player extends entities.Entity
			constructor: (x, y) ->
				super x, y, new gfx.Image 'player-sprite'

				@speed = 200

			update: ->
				dx = dy = 0
				dx += 1 if input.isDown 'right'
				dx -= 1 if input.isDown 'left'
				dy += 1 if input.isDown 'down'
				dy -= 1 if input.isDown 'up'

				if dx isnt 0 and dy isnt 0
					dx *= Math.SQRT1_2
					dy *= Math.SQRT1_2

				@pos.x += dx * @speed * app.elapsed
				@pos.y += dy * @speed * app.elapsed

		class PlayScene extends scenes.Scene
			constructor: ->
				super()
				@add new Player 50, 50

		return {
			PlayScene: PlayScene
		}