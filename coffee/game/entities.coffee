define ['core/app', 'core/entities', 'core/graphics',
	'core/input', 'core/particles', 'core/util',
	'core/ai/bt', 'game/entities/behaviours', 'game/guns'],
	(app, entities, gfx, input, particles, util, bt, behaviours, guns) ->
		ns = {}

		Entity		= entities.Entity
		Image		= gfx.Image
		random		= util.random

		class ns.Gun extends Entity
			constructor: ->
				super {
					graphic: new Image("gun-sprite", centered: true)
					width: 24
					layer: 150
					centered: true
				}
				@model = guns.GunModel.createRandom()

			update: ->
				super()
				@model.update()

			tryShooting: ->
				@model.tryShooting()

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

						@scene.remove this if @scene
						return true

					enemy: (enemy) =>
						@scene.remove this if @scene
						enemy.hit()
						return true

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
					wall: -> true

				@gun = new ns.Gun

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

				@gun.update()
				if input.isDown 'shoot'
						if @gun.tryShooting()
							dx = input.mouseX - @pos.x + @scene.camera.x
							dy = input.mouseY - @pos.y + @scene.camera.y
							shot = new ns.Shot @pos.x, @pos.y, 600, Math.atan2 dy, dx
							@scene.add shot

				if input.pressed 'grab'
					console.log 'pressed grab!'
				if input.released 'grab'
					console.log 'released grab!'

		class ns.Silverfish extends Entity
			constructor: (x, y) ->
				super
					x: x
					y: y
					graphic: (new Image 'silverfish-sprite', centered: true)
					width: 40
					centered: true
					type: 'enemy'

				@hits		= 3

				@collisionHandlers =
					wall: -> true

				@pauseAction = =>
					action = new coreActions.Delay Math.random()
					action.onEnd = =>
						@actions.push @moveAction()
					return action

				@moveAction = =>
					destination =
						x: @x + random.inRange -50, 50
						y: @y + random.inRange -50, 50

					action = new actions.MoveTo this, destination,
						speed: 200
						threshold: 5
						timeout: 1

					action.onEnd = =>
						@actions.push @pauseAction()
					return action

				@behaviour = bt.forever(
					bt.branch(
						bt.cond(
							bt.checkOnce(
								behaviours.closeTo(this, (=> @player), 50)),
							behaviours.flee(this, (=> @player),
								speed: 300
								minDistance: 150
							)
						),
						bt.loop(
							bt.randomDelay(0, 1),
							behaviours.wanderNearby(this,
								radius: 100
								speed: 200
								timeout: 1
								threshold: 20
							)
						)
					)
				)

			update: ->
				super()

				@player = @scene.entities.first "player"

				@behaviour.update()
				if @vel.x isnt 0 or @vel.y isnt 0
					@graphic.rotate Math.atan2(@vel.y, @vel.x)

			hit: ->
				--@hits

				if @hits <= 0
					loot = new ns.Gun
					loot.x = @x
					loot.y = @y
					@scene.add loot

					@scene.remove(this) if @scene

		return ns
