define ['core/app', 'core/entities', 'core/graphics',
	'core/input', 'core/particles'],
	(app, entities, gfx, input, particles) ->
		ns = {}

		Entity	= entities.Entity
		Image	= gfx.Image

		class ns.Wall extends Entity
			@WIDTH: 48

			constructor: (x, y) ->
				super x, y, new Image 'wall-sprite'
				@layer = 200

				@width	= @graphic.width
				@height	= @graphic.height

				@type = 'wall'

		class ns.Shot extends Entity
			constructor: (x, y, speed, direction) ->
				super x, y, new Image 'shot-sprite'

				@vel.x = speed * Math.cos direction
				@vel.y = speed * Math.sin direction

				@width	= @graphic.width
				@height	= @graphic.height
				@center()

				@graphic.rotate(direction).centerOrigin()
				@layer = 100

				@collisionHandlers =
					wall: =>
						@scene.particles.addEmitter
							type: "burst"
							x: @x
							y: @y
							amount: 1
							particle:
								image: "shot-spark-sprite"
								lifespan: [0.1, 0.2]
								speed: [50, 150]
								direction: Math.atan2(@vel.y, @vel.x) - Math.PI
								directionWiggle: 0.5

						@scene.remove this
						@vel.x = @vel.y = 0
						return true

		class ns.Player extends Entity
			constructor: (x, y) ->
				super x, y, new Image 'player-sprite'
				@graphic.centerOrigin()
				
				@width = @height = 40
				@center()

				@speed = 400

				@collisionHandlers =
					wall: -> return true

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
					dx = input.mouseX - @pos.x + @scene.camera.x
					dy = input.mouseY - @pos.y + @scene.camera.y
					shot = new ns.Shot @pos.x, @pos.y, 600, Math.atan2 dy, dx
					@scene.add shot

		return ns
