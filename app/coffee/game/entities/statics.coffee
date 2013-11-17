define ['core/app', 'core/entities', 'core/graphics',
	'core/util', 'game/consts', 'game/entities/graphics'],
	(app, entities, gfx, util, consts, entityGfx) ->
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
					static: true

		
		class ns.Floor extends Entity
			constructor: (x, y, color) ->
				super
					x: x
					y: y
					#graphic: random.any entityGfx.floorSprites
					graphic: (new gfx.Rect consts.TILE_WIDTH, consts.TILE_WIDTH, color or "white")
					layer: 300
					static: true

		class ns.Portal extends Entity
			constructor: (x, y) ->
				super
					x: x
					y: y
					centered: true
					graphic: (new gfx.Image 'portal-sprite', centered: true)
					layer: 100
					static: true

				play = require 'game/play'
				@collisionHandlers =
					player: ->
						app.scene = new play.PlayScene
		return ns
