define ['game/entities', 'core/util'], (entities, util) ->
	ns = {}

	Wall = entities.Wall

	class ns.Room
		@WIDTH	= 16
		@HEIGHT	= 16
		constructor: (@xIndex, @yIndex) ->
			@tiles = util.array2d Room.WIDTH, Room.HEIGHT

			for i in [0...Room.WIDTH]
				@tiles[i][0] = "wall"
				@tiles[i][Room.HEIGHT-1] = "wall"

			for j in [0...Room.HEIGHT]
				@tiles[0][j] = "wall"
				@tiles[Room.WIDTH-1][j] = "wall"

		realize: ->
			es = []
			@tiles.each (i, j, tile) =>
				x = @xIndex * Room.WIDTH * Wall.WIDTH + i * Wall.WIDTH
				y = @yIndex * Room.HEIGHT * Wall.WIDTH + j * Wall.WIDTH
				switch tile
					when "wall"
						es.push new Wall x, y

			return es

	class ns.Level
		@WIDTH	= 4
		@HEIGHT	= 4

		constructor: ->
			@rooms = util.array2d Level.WIDTH, Level.HEIGHT
			@rooms.each (i, j) =>
				@rooms[i][j] = new ns.Room i, j

		realize: ->
			es = []
			@rooms.each (_, _, room) ->
				es.push e for e in room.realize()
			return es

	return ns
