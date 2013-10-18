define ['core/app', 'core/scenes', 'core/entities', 'core/graphics',
	'core/input'],
	(app, scenes, entities, gfx, input) ->
		Entity	= entities.Entity
		Image	= gfx.Image

		class Wall extends Entity
			@WIDTH: 48

			constructor: (x, y) ->
				super x, y, new Image 'wall-sprite'
				@layer = 200

				@width	= @graphic.width
				@height	= @graphic.height

				@type = 'wall'

		class Shot extends Entity
			constructor: (x, y, speed, direction) ->
				super x, y, new Image 'shot-sprite'

				@vel.x = speed * Math.cos direction
				@vel.y = speed * Math.sin direction

				@width	= @graphic.width
				@height	= @graphic.height
				@center()

				@graphic.rotate(direction).centerOrigin()
				@layer = 100

			update: ->
				super()

				if @scene.collide this, 'wall'
					@scene.remove this

		class Player extends Entity
			constructor: (x, y) ->
				super x, y, new Image 'player-sprite'
				@graphic.centerOrigin()
				
				@width = @graphic.width
				@height = @graphic.height
				@center()

				@speed = 200

			update: ->
				super()

				dx = dy = 0
				dx += 1 if input.isDown 'right'
				dx -= 1 if input.isDown 'left'
				dy += 1 if input.isDown 'down'
				dy -= 1 if input.isDown 'up'

				if dx isnt 0 and dy isnt 0
					dx *= Math.SQRT1_2
					dy *= Math.SQRT1_2

				@vel.x = dx * @speed
				@vel.y = dy * @speed

				if input.isDown 'shoot'
					dx = input.mouseX - @pos.x
					dy = input.mouseY - @pos.y
					shot = new Shot @pos.x, @pos.y, 300, Math.atan2 dy, dx
					@scene.add shot

		class PlayScene extends scenes.Scene
			constructor: ->
				super()
				@add new Player app.width / 2, app.height / 2

				for x in [0..app.width] by Wall.WIDTH
					@add new Wall x, 0
					@add new Wall x, app.height - Wall.WIDTH
				for y in [0..app.height] by Wall.WIDTH
					@add new Wall 0, y
					@add new Wall app.width - Wall.WIDTH, y

		return {
			PlayScene: PlayScene
		}
