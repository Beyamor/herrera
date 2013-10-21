define ['game/entities', 'core/util'], (entities, util) ->
	Wall = entities.Wall

	class Room
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

			@tiles[Room.WIDTH/2][Room.HEIGHT/2] = "silverfish"

		fill: ->
			for i in [0...Room.WIDTH]
				for j in [0...Room.HEIGHT]
					@tiles[i][j] = "wall"

		open: (direction) ->
			switch direction
				when "left"
					@tiles[0][Room.HEIGHT/2] = null
					@tiles[0][Room.HEIGHT/2+1] = null
				when "right"
					@tiles[Room.WIDTH-1][Room.HEIGHT/2] = null
					@tiles[Room.WIDTH-1][Room.HEIGHT/2+1] = null
				when "up"
					@tiles[Room.WIDTH/2][0] = null
					@tiles[Room.WIDTH/2+1][0] = null
				when "down"
					@tiles[Room.WIDTH/2][Room.HEIGHT-1] = null
					@tiles[Room.WIDTH/2+1][Room.HEIGHT-1] = null

		realize: ->
			es = []
			@tiles.each (i, j, tile) =>
				x = @xIndex * Room.WIDTH * Wall.WIDTH + i * Wall.WIDTH
				y = @yIndex * Room.HEIGHT * Wall.WIDTH + j * Wall.WIDTH
				switch tile
					when "wall"
						es.push new Wall x, y
					when "silverfish"
						es.push new entities.Silverfish x, y

			return es

	class Level
		@WIDTH	= 4
		@HEIGHT	= 4

		constructor: ->
			@rooms = util.array2d Level.WIDTH, Level.HEIGHT
			@rooms.each (i, j) =>
				@rooms[i][j] = new Room i, j

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
					@rooms[i][j].fill()

		realize: ->
			es = []
			@rooms.each (_, _, room) ->
				es.push e for e in room.realize()
			return es

	return Level: Level
