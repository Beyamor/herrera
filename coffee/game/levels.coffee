define ['game/entities', 'core/util'], (entities, util) ->
	Wall = entities.Wall

	random = util.random

	class Room
		@WIDTH	= 16
		@HEIGHT	= 16
		constructor: (@xIndex, @yIndex) ->
			@tiles = util.array2d Room.WIDTH, Room.HEIGHT

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

			a = pointsInRegion(3, 1, Room.WIDTH-3, 4)
			a.sort (a, b) -> a.x - b.x

			b = pointsInRegion(Room.WIDTH-4, 3, Room.WIDTH-1, Room.HEIGHT-3)
			b.sort (a, b) -> a.y - b.y

			c = pointsInRegion(3, Room.HEIGHT - 4, Room.WIDTH-3, Room.HEIGHT-1)
			c.sort (a, b) -> b.x - a.x

			d = pointsInRegion(1, 3, 4, Room.HEIGHT-3)
			d.sort (a, b) -> b.y - a.y

			points = a.concat(b, c, d)
			for i in [0...Room.WIDTH]
				for j in [0...Room.HEIGHT]
					if util.pointInPoly {x: i, y: j}, points
						@tiles[i][j] = "floor"
		open: (direction) ->
			[openX, openY] = switch direction
					when "left"
						[0, Room.HEIGHT/2]
					when "right"
						[Room.WIDTH-1, Room.HEIGHT/2]
					when "up"
						[Room.WIDTH/2, 0]
					when "down"
						[Room.WIDTH/2, Room.HEIGHT-1]

			for {x: x, y: y} in util.bresenham {x: openX, y: openY}, {x: Room.WIDTH/2, y: Room.HEIGHT/2}
				@tiles[x][y] = "floor"

		finalize: ->
			@tiles.each (i, j, tile) =>
				if tile is null
					neighbouringFloor =
						(i > 0 and @tiles[i-1][j] is "floor") or
						(i < Room.WIDTH-1 and @tiles[i+1][j] is "floor") or
						(j > 0 and @tiles[i][j-1] is "floor") or
						(j < Room.HEIGHT-1 and @tiles[i][j+1] is "floor")

					if neighbouringFloor
						@tiles[i][j] = "wall"

	class StartRoom extends Room
		constructor: (xIndex, yIndex) ->
			super xIndex, yIndex

			for i in [0...Room.WIDTH]
				@tiles[i][0] = "wall"
				@tiles[i][Room.HEIGHT-1] = "wall"

			for j in [0...Room.HEIGHT]
				@tiles[0][j] = "wall"
				@tiles[Room.WIDTH-1][j] = "wall"

			for i in [1...Room.WIDTH-1]
				for j in [1...Room.HEIGHT-1]
					@tiles[i][j] = "floor"
		open: (direction) ->
			switch direction
				when "left"
					@tiles[0][Room.HEIGHT/2] = "floor"
				when "right"
					@tiles[Room.WIDTH-1][Room.HEIGHT/2] = "floor"
				when "up"
					@tiles[Room.WIDTH/2][0] = "floor"
				when "down"
					@tiles[Room.WIDTH/2][Room.HEIGHT-1] = "floor"

	class Level
		@WIDTH	= 4
		@HEIGHT	= 4

		constructor: ->
			@rooms = util.array2d Level.WIDTH, Level.HEIGHT
			@rooms.each (i, j) =>
				@rooms[i][j] =
					if i is 0 and j is 0
						new StartRoom i, j
					else
						new RegularRoom i, j

			@construct()

		construct: ->
			crossovers = (Math.floor(Math.random() * Level.HEIGHT) for i in [0...Level.WIDTH])

			# assuming the player always starts at (0,0)
			for j in [0...crossovers[0]]
				@rooms[0][j].open "down"
				@rooms[0][j+1].open "up"
			@rooms[0][crossovers[0]].open "right"

			for i in [1...Level.WIDTH]
				crossover	= crossovers[i]
				prevCrossover	= crossovers[i-1]

				@rooms[i][crossover].open "right" if i < Level.WIDTH-1
				@rooms[i][prevCrossover].open "left"

				unused = [0...Level.HEIGHT]
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
			x = tileX * Wall.WIDTH
			y = tileY * Wall.WIDTH

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
						entity.x += roomX * Room.WIDTH * Wall.WIDTH
						entity.y += roomY * Room.HEIGHT * Wall.WIDTH
						es.push entity
			return es

	return {
		Level: Level
		Reifier: Reifier
	}
