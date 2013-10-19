define ['game/entities'], (entities) ->
	ns = {}

	Wall = entities.Wall

	class ns.Room
		@WIDTH	= 16
		@HEIGHT	= 16
		constructor: ->
			@tiles = []
			for i in [0...Room.WIDTH]
				@tiles.push []
				for j in [0...Room.HEIGHT]
					@tiles[i].push null

			for i in [0...Room.WIDTH]
				@tiles[i][0] = "wall"
				@tiles[i][Room.HEIGHT-1] = "wall"

			for j in [0...Room.HEIGHT]
				@tiles[0][j] = "wall"
				@tiles[Room.WIDTH-1][j] = "wall"

		realize: ->
			es = []
			for i in [0...Room.WIDTH]
				for j in [0...Room.HEIGHT]
					switch @tiles[i][j]
						when "wall"
							es.push new Wall i * Wall.WIDTH, j * Wall.WIDTH

			return es

	return ns
