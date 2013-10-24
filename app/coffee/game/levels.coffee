define ['game/entities', 'core/util', 'game/consts'], (entities, util, consts) ->
	Wall = entities.Wall

	random = util.random

	TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
	ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
	LEVEL_WIDTH	= LEVEL_HEIGHT	= consts.LEVEL_WIDTH

	class Room
		constructor: (@xIndex, @yIndex) ->
			@tiles = util.array2d ROOM_WIDTH, ROOM_HEIGHT

	class EmptyRoom extends Room

	class RegularRoom extends Room
		constructor: (xIndex, yIndex) ->
			super xIndex, yIndex

			@build()

		build: ->
			pointsInRegion = (minX, minY, maxX, maxY) ->
				points = []
				numberOfPoints = random.intInRange(1, 4)
				for i in [0...numberOfPoints]
					points.push {
						x: random.intInRange(minX, maxX)
						y: random.intInRange(minY, maxY)
					}
				return points

			a = pointsInRegion(3, 1, ROOM_WIDTH-3, 4)
			a.sort (a, b) -> a.x - b.x

			b = pointsInRegion(ROOM_WIDTH-4, 3, ROOM_WIDTH-1, ROOM_HEIGHT-3)
			b.sort (a, b) -> a.y - b.y

			c = pointsInRegion(3, ROOM_HEIGHT - 4, ROOM_WIDTH-3, ROOM_HEIGHT-1)
			c.sort (a, b) -> b.x - a.x

			d = pointsInRegion(1, 3, 4, ROOM_HEIGHT-3)
			d.sort (a, b) -> b.y - a.y

			points = a.concat(b, c, d)
			for i in [0...ROOM_WIDTH]
				for j in [0...ROOM_HEIGHT]
					if util.pointInPoly {x: i, y: j}, points
						@tiles[i][j] = "floor"
		open: (direction) ->
			[openX, openY] = switch direction
					when "left"
						[0, ROOM_HEIGHT/2]
					when "right"
						[ROOM_WIDTH-1, ROOM_HEIGHT/2]
					when "up"
						[ROOM_WIDTH/2, 0]
					when "down"
						[ROOM_WIDTH/2, ROOM_HEIGHT-1]

			for {x: x, y: y} in util.bresenham {x: openX, y: openY}, {x: ROOM_WIDTH/2, y: ROOM_HEIGHT/2}
				@tiles[x][y] = "floor"

		finalize: ->
			@tiles.each (i, j, tile) =>
				if tile is null
					neighbouringFloor =
						(i > 0 and @tiles[i-1][j] is "floor") or
						(i < ROOM_WIDTH-1 and @tiles[i+1][j] is "floor") or
						(j > 0 and @tiles[i][j-1] is "floor") or
						(j < ROOM_HEIGHT-1 and @tiles[i][j+1] is "floor")

					if neighbouringFloor
						@tiles[i][j] = "wall"

	class StartRoom extends Room
		constructor: (xIndex, yIndex) ->
			super xIndex, yIndex

			for i in [0...ROOM_WIDTH]
				@tiles[i][0] = "wall"
				@tiles[i][ROOM_HEIGHT-1] = "wall"

			for j in [0...ROOM_HEIGHT]
				@tiles[0][j] = "wall"
				@tiles[ROOM_WIDTH-1][j] = "wall"

			for i in [1...ROOM_WIDTH-1]
				for j in [1...ROOM_HEIGHT-1]
					@tiles[i][j] = "floor"
		open: (direction) ->
			switch direction
				when "left"
					@tiles[0][ROOM_HEIGHT/2] = "floor"
				when "right"
					@tiles[ROOM_WIDTH-1][ROOM_HEIGHT/2] = "floor"
				when "up"
					@tiles[ROOM_WIDTH/2][0] = "floor"
				when "down"
					@tiles[ROOM_WIDTH/2][ROOM_HEIGHT-1] = "floor"

	class Level
		@WIDTH	= 4
		@HEIGHT	= 4

		constructor: ->
			@rooms = util.array2d LEVEL_WIDTH, LEVEL_HEIGHT
			@rooms.each (i, j) =>
				@rooms[i][j] =
					if i is 0 and j is 0
						new StartRoom i, j
					else
						new RegularRoom i, j

			@construct()

		construct: ->
			crossovers = (Math.floor(Math.random() * LEVEL_HEIGHT) for i in [0...LEVEL_WIDTH])

			# assuming the player always starts at (0,0)
			for j in [0...crossovers[0]]
				@rooms[0][j].open "down"
				@rooms[0][j+1].open "up"
			@rooms[0][crossovers[0]].open "right"

			for i in [1...LEVEL_WIDTH]
				crossover	= crossovers[i]
				prevCrossover	= crossovers[i-1]

				@rooms[i][crossover].open "right" if i < LEVEL_WIDTH-1
				@rooms[i][prevCrossover].open "left"

				unused = [0...LEVEL_HEIGHT]
				unused.remove crossover

				for j in [prevCrossover...crossover]
					unused.remove j

					if prevCrossover < crossover
						@rooms[i][j].open "down"
						@rooms[i][j+1].open "up"
					else
						@rooms[i][j].open "up"
						@rooms[i][j-1].open "down"

				for j in unused
					@rooms[i][j] = new EmptyRoom i, j

			@rooms.each (_, _, room) ->
				room.finalize() if room.finalize?

	class Reifier
		reifyEntity: (tileX, tileY, tile) ->
			x = tileX * TILE_WIDTH
			y = tileY * TILE_HEIGHT

			switch tile
				when "wall"
					new Wall x, y
				when "floor"
					new entities.Floor x, y
				when "silverfish"
					new entities.Silverfish x, y
				when "barrel"
					new entities.Barrel x, y

		reify: (level) ->
			es = []

			level.rooms.each (roomX, roomY, room) =>
				room.tiles.each (tileX, tileY, tile) =>
					entity = @reifyEntity tileX, tileY, tile
					if entity
						entity.x += roomX * ROOM_WIDTH * TILE_WIDTH
						entity.y += roomY * ROOM_HEIGHT * TILE_HEIGHT
						es.push entity
			return es

	return {
		Level: Level
		Reifier: Reifier
	}
