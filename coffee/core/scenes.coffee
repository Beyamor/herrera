define ['core/debug', 'core/app', 'core/cameras', 'core/util'], (debug, app, cameras, util) ->
	CELL_WIDTH = CELL_HEIGHT = 200

	class Scene
		constructor: ->
			@entities	= []
			@toAdd		= []
			@toRemove	= []
			@camera		= new cameras.Camera

		add: (e) ->
			return unless e?
			@toAdd.push e

		remove: (e) ->
			return unless e?
			@toRemove.push e

		update: ->
			minX = minY = Infinity
			maxX = maxY = -Infinity

			if @entities.length > 0
				for entity in @entities
					minX = Math.min minX, entity.x
					maxX = Math.max maxX, entity.x
					minY = Math.min minY, entity.y
					maxY = Math.max maxY, entity.y

				@minCellX = Math.floor(minX / CELL_WIDTH)
				@maxCellX = Math.ceil(maxX / CELL_WIDTH)
				@minCellY = Math.floor(minY / CELL_HEIGHT)
				@maxCellY = Math.ceil(maxY / CELL_HEIGHT)

				@entityCells = util.array2d (@maxCellX - @minCellX + 1), (@maxCellY - @minCellY + 1), -> []

			for entity in @entities
				minCellX = Math.floor(entity.left / CELL_WIDTH)
				maxCellX = Math.ceil(entity.right / CELL_WIDTH)
				minCellY = Math.floor(entity.top / CELL_HEIGHT)
				maxCellY = Math.ceil(entity.bottom / CELL_HEIGHT)

				for x in [minCellX..maxCellX]
					for y in [minCellY..maxCellY]
						@entityCells[x][y].push entity

			entity.update() for entity in @entities

			if @toAdd.length isnt 0
				for entity in @toAdd
					entity.scene = this
					@entities.push entity
				@entities.sort (a, b) -> b.layer - a.layer
				@toAdd = []

			if @toRemove.length isnt 0
				for entity in @toRemove
					index = @entities.indexOf entity
					if index != -1
						@entities.splice index, 1
					entity.scene = null
				@toRemove = []

			@camera.update()

		render: ->
			entity.render() for entity in @entities

			if debug.isEnabled 'hitboxes'
				for entity in @entities
					context = app.canvas.context
					context.beginPath()
					context.rect(
						entity.pos.x + entity.offset.x - @camera.x,
						entity.pos.y + entity.offset.y - @camera.y,
						entity.width,
						entity.height
					)
					context.strokeStyle = 'red'
					context.stroke()

		roughCollisions: (entity) ->
			minCellX = Math.floor(entity.left / CELL_WIDTH)
			maxCellX = Math.ceil(entity.right / CELL_WIDTH)
			minCellY = Math.floor(entity.top / CELL_HEIGHT)
			maxCellY = Math.ceil(entity.bottom / CELL_HEIGHT)

			candidates = []
			for x in [minCellX..maxCellX]
				for y in [minCellY..maxCellY]
					candidates = candidates.concat @entityCells[x][y]

			return candidates


		collide: (e1, type) ->
			for e2 in @roughCollisions(e1) when e2 isnt e1 and e2.hasType type
				return e2 if util.aabbsIntersect e1, e2
			return null

	return {
		Scene: Scene
	}
