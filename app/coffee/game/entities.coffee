define ['core/app', 'core/entities', 'core/graphics',
	'core/input', 'core/particles', 'core/util',
	'core/ai/bt', 'game/entities/behaviours', 'game/guns',
	'game/consts',  'game/entities/graphics',
	'game/mixins', 'core/debug', 'game/entities/items'],
	(app, entities, gfx, input, particles, util, bt, behaviours, \
	guns, consts, entityGfx, gameMixins, debug, items) ->
		ns = {}

		Entity		= entities.Entity
		Image		= gfx.Image
		random		= util.random

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
			constructor: (x, y, speed, direction, @damage) ->
				super
					x: x
					y: y
					graphic: (new Image 'shot-sprite', centered: true)
					width: 8
					layer: 100
					centered: true
					mixins:
						straightMover:
							speed: speed
							direction: direction
						rotateGraphicToVel: true

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
						hittable.hit
							source: this
							damage: @damage
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
					mixins:
						updates: [
							-> @gun
						]
				
				@speed = 400

				@collisionHandlers =
					wall: -> not debug.isEnabled "passThuWalls"

				@gun = guns.GunModel.createRandom()

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
								shot = new ns.Shot @pos.x, @pos.y,
										600, Math.atan2(dy, dx),
										@gun.damage
								@scene.add shot

				itemOfInterest = @scene.entities.collide this, 'item'
				if itemOfInterest and input.pressed 'grab'
					itemOfInterest.equip this

				if input.pressed 192 # ~
					debug.toggle "passThuWalls"

		class ns.Silverfish extends Entity
			constructor: (x, y) ->
				super
					x: x
					y: y
					graphic: (new Image 'silverfish-sprite', centered: true)
					width: 40
					centered: true
					type: 'hittable'
					mixins:
						rotateGraphicToVel: true
						updates: [
							-> @behaviour
						]

				@hp = 30

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
							bt.seq(
								behaviours.flee(this, (=> @player),
									speed: 425
									minDistance: 150
								)
							)
						),
						bt.cond(
							bt.test(=> @escaping),
							bt.seq(
								behaviours.flee(this, (=> @escapingPoint),
									speed: 425
									minDistance: 150
									timeout: 1
								),
								bt.cb(=> @escaping = false)
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
				@player = @scene.entities.first "player"
				super()

			hit: ({damage: damage, source: source}) ->
				@hp -= damage

				@scene.add new ns.DamageCounter @x, @y, damage

				if @hp <= 0
					loot = items.for guns.GunModel.createRandom()
					loot.x = @x
					loot.y = @y
					@scene.add loot

					@scene.remove(this) if @scene

				else
					@escaping	= true
					@escapingPoint	= {x: source.x, y: source.y}

		class ns.DamageCounter extends Entity
			constructor: (x, y, damage) ->
				super {
					x: x
					y: y
					graphic: new entityGfx.DamageCounterSprite damage
					layer: -50
					mixins:
						straightMover:
							speed: [50, 80]
							direction: [0, 2 * Math.PI]

						lifespan: [0.2, 0.3]
				}

		return ns
