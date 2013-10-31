define ['core/app', 'core/util'], (app, util) ->
	ns = {}

	CELL_WIDTH = CELL_HEIGHT = 200

	class ns.Entity
		constructor: (args) ->
			@pos			= {x: args.x, y: args.y}
			@graphic		= args.graphic
			@vel			= {x: 0, y: 0}
			@layer			= args.layer or 0
			@width			= args.width or 0
			@height			= args.height or args.width or 0
			@offset			= {x: 0, y: 0}
			@collisionHandlers	= {}
			@type			= args.type
			@static			= args.static

			@center() if args.centered?

		center: ->
			@offset.x = -@width * 0.5
			@offset.y = -@height * 0.5

		collide: (type, x, y) ->
			return null unless @scene
			prevX = @pos.x
			prevY = @pos.y
			@pos.x = x
			@pos.y = y

			result = @scene.entities.collide this, type

			@pos.x = prevX
			@pos.y = prevY

			return result

		move: ->
			xSteps	= Math.floor(Math.abs(@vel.x * app.elapsed))
			xInc 	= util.sign(@vel.x)

			stop = false
			while xSteps > 0
				for type, handler of @collisionHandlers
					collision = @collide type, @pos.x + xInc, @pos.y
					if collision
						stop = handler(collision)
					break if stop

				break if stop
				@pos.x += xInc
				xSteps -= 1

			ySteps	= Math.floor(Math.abs(@vel.y * app.elapsed))
			yInc 	= util.sign(@vel.y)

			stop = false
			while ySteps > 0
				for type, handler of @collisionHandlers
					collision = @collide type, @pos.x, @pos.y + yInc
					if collision
						stop = handler(collision)
					break if stop

				break if stop
				@pos.y += yInc
				ySteps -= 1

		update: ->
			if @vel.x isnt 0 or @vel.y isnt 0
				@move()
			else
				for type, handler of @collisionHandlers
					collision = @collide type, @pos.x, @pos.y
					handler(collision) if collision
			
		render: ->
			return unless @graphic and @scene and @scene.camera
			@graphic.render app.canvas, @pos, @scene.camera

		hasType: (type) ->
			@type? and @type is type

		@accessors
			left:
				get: -> @pos.x + @offset.x

			right:
				get: -> @left + @width

			top:
				get: -> @pos.y + @offset.y

			bottom:
				get: -> @top + @height

			x:
				get: -> @pos.x
				set: (x) -> @pos.x = x

			y:
				get: -> @pos.y
				set: (y) -> @pos.y = y

	class BaseEntityList
		constructor: ->
			@list		= []
			@toAdd	 	= []
			@toRemove	= []
			@entityCells	= {}

		add: (e) ->
			return unless e?
			@toAdd.push e

		remove: (e) ->
			return unless e?
			@toRemove.push e

		cellBounds: (e) ->
			return {
				minCellX: Math.floor(e.left / CELL_WIDTH)
				maxCellX: Math.ceil(e.right / CELL_WIDTH)
				minCellY: Math.floor(e.top / CELL_HEIGHT)
				maxCellY: Math.ceil(e.bottom / CELL_HEIGHT)
			}

		addToCells: (e) ->
			bounds = @cellBounds e

			for x in [bounds.minCellX..bounds.maxCellX]
				@entityCells[x] or= {}
				for y in [bounds.minCellY..bounds.maxCellY]
					@entityCells[x][y] or= []
					@entityCells[x][y].push e

		removeFromCells: (e) ->
			bounds = @cellBounds e

			for x in [bounds.minCellX..bounds.maxCellX]
				for y in [bounds.minCellY..bounds.maxCellY]
					@entityCells[x][y].remove e

		update: ->
			if @toAdd.length isnt 0
				for entity in @toAdd
					@list.push entity
				@toAdd = []

			if @toRemove.length isnt 0
				for entity in @toRemove
					index = @list.indexOf entity
					if index != -1
						@list.splice index, 1
				@toRemove = []

		render: ->
			entity.render() for entity in @list

		inBounds: (rect) ->
			bounds = @cellBounds rect

			es = []

			if @entityCells
				for x in [bounds.minCellX..bounds.maxCellX]
					for y in [bounds.minCellY..bounds.maxCellY]
						if @entityCells[x] and @entityCells[x][y]
							es = es.concat @entityCells[x][y]

			return es


		first: (type) ->
			(return e) for e in @list when e.hasType type
			return null

		rebuildCells: ->
			@entityCells = {}
			@addToCells(entity) for entity in @list

	class StaticEntityList extends BaseEntityList
		add: (e) ->
			@addToCells e
			super e

		remove: (e) ->
			@removeFromCells e
			super e

		update: ->
			entity.update() for entity in @list
			super()

	class DynamicEntityList extends BaseEntityList
		update: ->
			@rebuildCells()
			for entity in @list
				# so, this isn't perfect
				# cause, like, what if this entity moves some other one?
				# but whatever, probably good enough to just handle this case
				prevX = entity.x
				prevY = entity.y

				entity.update()

				if entity.x isnt prevX or entity.y isnt prevY
					newX = entity.x
					newY = entity.y

					entity.x = prevX
					entity.y = prevY
					@removeFromCells(entity)

					entity.x = newX
					entity.y = newY
					@addToCells(entity)

			super()

	class ns.EntityList
		constructor: ->
			@statics	= new StaticEntityList
			@dynamics	= new DynamicEntityList

		add: (e) ->
			return unless e
			if e.static then @statics.add e else @dynamics.add e

		remove: (e) ->
			return unless e
			if e.static then @statics.remove e else @dynamics.remove e

		update: ->
			@statics.update()
			@dynamics.update()

		inBounds: (rect) ->
			@statics.inBounds(rect).concat @dynamics.inBounds(rect)

		collide: (e1, type) ->
			for e2 in @inBounds(e1) when e2 isnt e1 and e2.hasType type
				return e2 if util.aabbsIntersect e1, e2
			return null

		first: (type) ->
			@statics.first(type) or @dynamics.first(type)

	return ns
