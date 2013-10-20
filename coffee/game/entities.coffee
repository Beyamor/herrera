define ['core/app', 'core/entities', 'core/graphics',
	'core/input', 'core/particles', 'core/util'],
	(app, entities, gfx, input, particles, util) ->
		ns = {}

		Entity	= entities.Entity
		Image	= gfx.Image

		class ns.Wall extends Entity
			@WIDTH: 48
			@LAYER: 200

			constructor: (x, y) ->
				super
					x: x
					y: y
					graphic: new Image 'wall-sprite'
					width: ns.Wall.WIDTH
					layer: ns.Wall.LAYER
					type: 'wall'

		class ns.Shot extends Entity
			constructor: (x, y, speed, direction) ->
				super
					x: x
					y: y
					graphic: (new Image 'shot-sprite', centered: true)
					width: 8
					layer: 100
					centered: true

				@vel.x = speed * Math.cos direction
				@vel.y = speed * Math.sin direction

				@graphic.rotate(direction).centerOrigin()

				@collisionHandlers =
					wall: =>
						@scene.particles.addEmitter
							type: "burst"
							x: @x
							y: @y
							amount: 3
							particle:
								image: "shot-smoke-sprite"
								lifespan: [0.2, 0.4]
								speed: [10, 40]
								direction: Math.atan2(@vel.y, @vel.x) - Math.PI
								directionWiggle: 2
								layer: ns.Wall.LAYER + 1

						@scene.remove this
						return true

					enemy: (enemy) =>
						@scene.remove this
						enemy.hit()
						return true

			#added: ->
			#	@smoke = @scene.particles.addEmitter
			#		type: "continuous"
			#		amount: 1
			#		particle:
			#			image: "shot-smoke-sprite"
			#			lifespan: [0.3, 0.5]
			#			direction: Math.atan2(@vel.y, @vel.x) - Math.PI
			#			speed: [2, 5]
			#			directionWiggle: 0.5

			#removed: ->
			#	@smoke.kill()

			#update: ->
			#	super()
			#	@smoke.x = @x
			#	@smoke.y = @y

		class ns.Player extends Entity
			constructor: (x, y) ->
				super
					x: x
					y: y
					graphic: (new Image 'player-sprite', centered: true)
					width: 40
					centered: true
					type: 'player'
				
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

		class ns.Silverfish extends Entity
			constructor: (x, y) ->
				super
					x: x
					y: y
					graphic: (new Image 'silverfish-sprite', centered: true)
					width: 40
					centered: true
					type: 'enemy'

				@hits = 3

			update: ->
				player	= @scene.entities.first 'player'
				@graphic.rotate util.directionFrom this, player

			hit: ->
				--@hits

				if @hits <= 0
					@scene.remove this

		return ns
