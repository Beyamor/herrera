define ['core/app', 'core/entities',
	'core/graphics', 'core/util',
	'game/consts', 'core/canvas'],
	(app, entities, gfx, util, consts, canvas) ->
		ns = {}

		Entity		= entities.Entity
		Image		= gfx.Image
		random		= util.random

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

				margin = 1
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

		return ns
