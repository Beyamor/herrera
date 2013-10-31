define ['core/app', 'core/entities', 'core/graphics',
	'core/input', 'core/particles', 'core/util',
	'core/ai/bt', 'game/entities/behaviours', 'game/guns',
	'game/consts', 'core/canvas'],
	(app, entities, gfx, input, particles, util, bt, behaviours, guns, consts, canvas) ->
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
					type: 'gun'
					centered: true
				}
				@model = guns.GunModel.createRandom()

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
						layer: ns.Wall.LAYER + 1

				@scene.remove this

		class ns.Wall extends Entity
			@LAYER: 200

			constructor: (x, y) ->
				super
					x: x
					y: y
					graphic: new Image 'wall-sprite'
					width: consts.TILE_WIDTH
					layer: ns.Wall.LAYER
					type: 'wall'

		class FloorSprite
			constructor: ->
				@canvas	= new canvas.Canvas width: consts.TILE_WIDTH+1, height: consts.TILE_WIDTH+1
				@prerender()

			prerender: ->
				features = []
				tileColors = [
					[0x8A, 0x82, 0x6A]
					[0x7D, 0x69, 0x4C]
					[0x6B, 0x5B, 0x49]
				]
				for i in [0...random.intInRange(4, 6)]
					tooClose = true
					while tooClose
						x = random.inRange 0, consts.TILE_WIDTH
						y = random.inRange 0, consts.TILE_WIDTH

						tooClose = false
						for feature in features
							dx		= feature.x - x
							dy		= feature.y - y
							distance	= dx*dx + dy*dy

							if distance < 35
								tooClose = true
								break

					features.push {
						x: x
						y: y
						color: tileColors[i % tileColors.length]
					}

				margin = 2
				for x in [margin...consts.TILE_WIDTH - margin]
					for y in [margin...consts.TILE_WIDTH - margin]
						closestFeature		= null
						smallestDistance1	= Infinity
						smallestDistance2	= Infinity

						for feature in features
							dx = feature.x - x
							dy = feature.y - y

							distance = dx * dx + dy * dy

							if distance < smallestDistance1
								smallestDistance1	= distance
								closestFeature		= feature
							else if distance < smallestDistance2
								smallestDistance2	= distance

						color =
							if Math.sqrt(smallestDistance2) - Math.sqrt(smallestDistance1) < 3
								[0x0A, 0x07, 0x05]
							else
								closestFeature.color

						@canvas.drawPixel x, y, color

				context = @canvas.context
				context.beginPath()
				context.rect(0, 0, @canvas.width, margin)
				context.rect(0, 0, margin, @canvas.height)
				context.rect(0, @canvas.height - 1 - margin, @canvas.width, margin)
				context.rect(@canvas.width - 1 - margin, 0, margin, @canvas.height)
				context.fillStyle = "#0A0705"
				context.fill()

			render: (target, point, camera) ->
				x = point.x - camera.x
				y = point.y - camera.y
				target.context.drawImage @canvas.el, x, y
		floorSprites = (new FloorSprite for i in [0...100])

		class ns.Floor extends Entity
			constructor: (x, y) ->
				super
					x: x
					y: y
					graphic: random.any floorSprites
					layer: 300

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
				dx += 1 if input.isDown 'right'
				dx -= 1 if input.isDown 'left'
				dy += 1 if input.isDown 'down'
				dy -= 1 if input.isDown 'up'

				if dx isnt 0 and dy isnt 0
					dx *= Math.SQRT1_2
					dy *= Math.SQRT1_2

				@vel.x = dx * @speed
				@vel.y = dy * @speed

				if @gun
					@gun.update()
					if input.isDown 'shoot'
							if @gun.tryShooting()
								dx = input.mouseX - @pos.x + @scene.camera.x
								dy = input.mouseY - @pos.y + @scene.camera.y
								shot = new ns.Shot @pos.x, @pos.y, 600, Math.atan2 dy, dx
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
