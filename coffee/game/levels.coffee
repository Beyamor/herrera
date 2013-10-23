define ['game/entities', 'core/util'], (entities, util) ->
	Wall = entities.Wall

	class Room
		@WIDTH	= 20
		@HEIGHT	= 20
		constructor: (@xIndex, @yIndex) ->
			@tiles = util.array2d Room.WIDTH, Room.HEIGHT

		open: (direction) ->
			switch direction
				when "left"
					@tiles[0][Room.HEIGHT/2] = "floor"
					@tiles[0][Room.HEIGHT/2+1] = "floor"
				when "right"
					@tiles[Room.WIDTH-1][Room.HEIGHT/2] = "floor"
					@tiles[Room.WIDTH-1][Room.HEIGHT/2+1] = "floor"
				when "up"
					@tiles[Room.WIDTH/2][0] = "floor"
					@tiles[Room.WIDTH/2+1][0] = "floor"
				when "down"
					@tiles[Room.WIDTH/2][Room.HEIGHT-1] = "floor"
					@tiles[Room.WIDTH/2+1][Room.HEIGHT-1] = "floor"

	class RegularRoom extends Room
		constructor: (xIndex, yIndex) ->
			super xIndex, yIndex

			@build()

		build: ->

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
