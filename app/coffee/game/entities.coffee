define ['core/app', 'core/entities', 'core/graphics',
	'core/input', 'core/particles', 'core/util',
	'core/ai/bt', 'game/entities/behaviours', 'game/guns',
	'game/consts', 'core/canvas', 'game/guns/sprites'],
	(app, entities, gfx, input, particles, util, bt, behaviours, guns, consts, canvas, gunSprites) ->
		ns = {}

		Entity		= entities.Entity
		Image		= gfx.Image
		random		= util.random

		class ns.Gun extends Entity
			constructor: ->
				@model = guns.GunModel.createRandom()

				super {
					graphic: new gunSprites.GunSprite @model.model
					width: 24
					layer: 150
					type: 'gun'
					centered: true
				}

			update: ->
				super()
				@model.update()

			tryShooting: ->
				@model.tryShooting()

		class ns.Barrel extends Entity
			constructor: (x, y) ->
				super
					x: x
					y: y
					graphic: new Image('barrel-sprite', centered: true)
					width: 24
					layer: 175
					type: 'hittable'
					centered: true

			hit: ->
				@scene.particles.addEmitter
					type: "burst"
					x: @x
					y: @y
					amount: 10
					particle:
						image: "shot-smoke-sprite"
						lifespan: [0.2, 0.5]
						speed: [10, 30]
						direction: [0, Math.PI * 2]
						layer: 250

				@scene.remove this

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
								layer: 250

						@scene.remove this if @scene
						return true

					hittable: (hittable) =>
						@scene.remove this if @scene
						hittable.hit()
						return true

		class ns.Player extends Entity
			constructor: (x, y) ->
				super
					x: x
					y: y
					graphic: (new Image 'player-sprite', centered: true)
					width: 36
					centered: true
					type: 'player'
				
				@speed = 400

				@collisionHandlers =
					wall: -> true

				@gun = new ns.Gun

			update: ->
				super()

				dx = dy = 0
				dx += 1 if input.isDown 'walkRight'
				dx -= 1 if input.isDown 'walkLeft'
				dy += 1 if input.isDown 'walkDown'
				dy -= 1 if input.isDown 'walkUp'

				if dx isnt 0 and dy isnt 0
					dx *= Math.SQRT1_2
					dy *= Math.SQRT1_2

				@vel.x = dx * @speed
				@vel.y = dy * @speed

				if @gun
					@gun.update()

					dx = 0
					dy = 0
					tryingToShoot = false

					if input.isDown 'aimUp'
						dy -= 1
						tryingToShoot = true
					if input.isDown 'aimDown'
						dy += 1
						tryingToShoot = true
					if input.isDown 'aimRight'
						dx += 1
						tryingToShoot = true
					if input.isDown 'aimLeft'
						dx -= 1
						tryingToShoot = true

					if tryingToShoot
							if @gun.tryShooting()
								shot = new ns.Shot @pos.x, @pos.y, 600, Math.atan2(dy, dx)
								@scene.add shot

				if input.pressed 'grab'
					gun = @scene.entities.collide this, 'gun'

					if gun
						if @gun
							@gun.x = @x
							@gun.y = @y
							@scene.add @gun
						@scene.remove gun
						@gun = gun

		class ns.Silverfish extends Entity
			constructor: (x, y) ->
				super
					x: x
					y: y
					graphic: (new Image 'silverfish-sprite', centered: true)
					width: 40
					centered: true
					type: 'hittable'

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
								speed: 425
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
