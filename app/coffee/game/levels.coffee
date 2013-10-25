define ['game/entities', 'core/util', 'game/consts', 'game/room-data'], (entities, util, consts, definitions) ->
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
			@exits = []

		addEntrance: (direction) ->
			@entrance = direction

		addExit: (direction) ->
			@exits.push direction

		finalize: ->
			possibilities = []
			for room in definitions.rooms
				for orientation in room.orientations
					continue unless orientation.entrance is @entrance

					meetsAllExits = true
					for exit in @exits
						meetsAllExits and= (orientation.exits.indexOf(exit) isnt -1)

					continue unless meetsAllExits
					possibilities.push {
						definition: room.definition
						transformation: orientation.transformation
					}

			throw new Error("no room possibilities (entrance is #{@entrance})") unless possibilities.length isnt 0
			choice = random.any possibilities

			tiles = @applyTransformation choice.definition, choice.transformation
			@tiles.each (i, j) => @tiles[i][j] = tiles[i + j * ROOM_WIDTH]

		applyTransformation: (definition, transformation) ->
			result = util.copy definition

			get = (i, j) -> definition[i + j * ROOM_WIDTH]
			set = (i, j, value) -> result[i + j * ROOM_WIDTH] = value

			if transformation
				if transformation.rotation is 90
					for i in [0...ROOM_WIDTH]
						for j in [0...ROOM_HEIGHT]
							set(i, j, get(j, ROOM_WIDTH - 1 - i))

				else if transformation.rotation is 180
					for i in [0...ROOM_WIDTH]
						for j in [0...ROOM_HEIGHT]
							set(i, j, get(ROOM_WIDTH - 1 - i, ROOM_HEIGHT - 1 - j))

				else if transformation.rotation is 270
					for i in [0...ROOM_WIDTH]
						for j in [0...ROOM_HEIGHT]
							set(i, j, get(ROOM_HEIGHT - 1 - j, i))

				 if transformation.mirror is "vertical"
					for i in [0...ROOM_WIDTH]
						for j in [0...ROOM_HEIGHT]
							set(i, j, get(i, ROOM_HEIGHT - 1 - j))
				else if transformation.mirror is "horizontal"
					for i in [0...ROOM_WIDTH]
						for j in [0...ROOM_HEIGHT]
							set(i, j, get(ROOM_WIDTH - 1 - i, j))


			return result


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
		addExit: (direction) ->
			switch direction
				when "west"
					@tiles[0][ROOM_HEIGHT/2] = "floor"
				when "east"
					@tiles[ROOM_WIDTH-1][ROOM_HEIGHT/2] = "floor"
				when "north"
					@tiles[ROOM_WIDTH/2][0] = "floor"
				when "south"
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

			@construct()

		construct: ->
			crossovers = (Math.floor(Math.random() * LEVEL_HEIGHT) for i in [0...LEVEL_WIDTH])

			# assuming the player always starts at (0,0)
			for j in [0...crossovers[0]]
				@rooms[0][j].addExit "south"
				@rooms[0][j+1] or= new RegularRoom 0, j+1
				@rooms[0][j+1].addEntrance "north"
			@rooms[0][crossovers[0]].addExit "east"

			for i in [1...LEVEL_WIDTH]
				crossover	= crossovers[i]
				prevCrossover	= crossovers[i-1]

				@rooms[i][crossover] or= new RegularRoom i, crossover
				@rooms[i][crossover].addExit "east" if i < LEVEL_WIDTH-1

				@rooms[i][prevCrossover] or= new RegularRoom i, prevCrossover
				@rooms[i][prevCrossover].addEntrance "west"

				unused = [0...LEVEL_HEIGHT]
				unused.remove crossover

				for j in [prevCrossover...crossover]
					unused.remove j

					@rooms[i][j] or= new RegularRoom i, j

					if prevCrossover < crossover
						@rooms[i][j+1] or= new RegularRoom i, j
						@rooms[i][j].addExit "south"
						@rooms[i][j+1].addEntrance "north"
					else
						@rooms[i][j-1] or= new RegularRoom i,j
						@rooms[i][j].addExit "north"
						@rooms[i][j-1].addEntrance "south"

			@rooms.each (_, _, room) ->
				room.finalize() if room and room.finalize?

	class Reifier
		reifyEntity: (tileX, tileY, tile) ->
			x = tileX * TILE_WIDTH
			y = tileY * TILE_HEIGHT

			switch tile
				when "wall"
					new Wall x, y
				when "W"
					new Wall x, y
				when "floor"
					new entities.Floor x, y
				when "."
					new entities.Floor x, y
				when "silverfish"
					new entities.Silverfish x, y
				when "barrel"
					new entities.Barrel x, y

		reify: (level) ->
			es = []

			level.rooms.each (roomX, roomY, room) =>
				if room
					room.tiles.each (tileX, tileY, tile) =>
						entity = @reifyEntity tileX, tileY, tile
						if entity
							entity.x += roomX * (ROOM_WIDTH + 1) * TILE_WIDTH
							entity.y += roomY * (ROOM_HEIGHT + 1) * TILE_HEIGHT
							es.push entity
			return es

	return {
		Level: Level
		Reifier: Reifier
	}
