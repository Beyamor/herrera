define ['game/entities', 'game/entities/statics', 'core/util', 'game/consts', 'game/rooms'],
	(entities, staticEntities, util, consts, rooms) ->
		StartRoom	= rooms.StartRoom
		RegularRoom	= rooms.RegularRoom

		TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
		ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
		LEVEL_WIDTH	= LEVEL_HEIGHT	= consts.LEVEL_WIDTH

		random = util.random

		class Level
			constructor: ->
				@rooms = util.array2d LEVEL_WIDTH, LEVEL_HEIGHT
				@rooms[0][0] = new StartRoom 0, 0

				tileWidth	= LEVEL_WIDTH * (ROOM_WIDTH + 1)
				tileHeight	= LEVEL_HEIGHT * (ROOM_HEIGHT + 1)
				@tiles		= util.array2d tileWidth * tileHeight

				@construct()

			construct: ->
				crossovers	= (Math.floor(Math.random() * LEVEL_HEIGHT) for i in [0...LEVEL_WIDTH])
				@connections	= []

				# assuming the player always starts at (0,0)
				for j in [0...crossovers[0]]
					@rooms[0][j+1] or= new RegularRoom 0, j+1
					@connections.push {from: @rooms[0][j], to: @rooms[0][j+1], direction: "south"}

				for i in [1...LEVEL_WIDTH]
					crossover	= crossovers[i]
					prevCrossover	= crossovers[i-1]

					@rooms[i][crossover] or= new RegularRoom i, crossover

					@rooms[i][prevCrossover] or= new RegularRoom i, prevCrossover
					@connections.push {
						from: @rooms[i-1][prevCrossover],
						to: @rooms[i][prevCrossover],
						direction: "east"
					}

					unused = [0...LEVEL_HEIGHT]
					unused.remove crossover

					for j in [prevCrossover...crossover]
						unused.remove j

						@rooms[i][j] or= new RegularRoom i, j

						if prevCrossover < crossover
							@rooms[i][j+1] or= new RegularRoom i, j+1
							@connections.push {from: @rooms[i][j], to: @rooms[i][j+1], direction: "south"}
						else
							@rooms[i][j-1] or= new RegularRoom i,j-1
							@connections.push {from: @rooms[i][j], to: @rooms[i][j-1], direction: "north"}

				for {from: from, to: to, direction: direction} in @connections
					from.addExit direction
					to.addEntrance util.oppositeDirection(direction)

				@rooms.each (_, _, room) ->
					room.finalize() if room and room.finalize?

				for {from: from, to: to, direction: direction} in @connections
					exit		= from.exits[direction]
					entrance	= to.entrance

					path = []
					switch direction
						when "south"
							middleY = @levelY(to, -1)

							for y in [@levelY(from, exit.y+1)...middleY]
								path.push [@levelX(from, exit.x), y]

							for x in [@levelX(from, exit.x)..@levelX(to, entrance.x)]
								path.push [x, middleY]

							for y in [@levelY(to, entrance.y-1)...middleY]
								path.push [@levelX(to, entrance.x), y]

						when "north"
							middleY = @levelY(from, -1)

							for y in [@levelY(from, exit.y-1)...middleY]
								path.push [@levelX(from, exit.x), y]

							for x in [@levelX(from, exit.x)..@levelX(to, entrance.x)]
								path.push [x, middleY]

							for y in [@levelY(to, entrance.y+1)...middleY]
								path.push [@levelX(to, entrance.x), y]

						when "east"
							middleX = @levelX(to, -1)

							for x in [@levelX(from, exit.x+1)...middleX]
								path.push [x, @levelY(from, exit.y)]

							for y in [@levelY(from, exit.y)..@levelY(to, entrance.y)]
								path.push [middleX, y]

							for x in [@levelX(to, entrance.x-1)...middleX]
								path.push [x, @levelY(to, entrance.y)]

						when "west"
							middleX = @levelX(from, -1)

							for x in [@levelX(from, exit.x-1)...middleX]
								path.push [x, @levelY(from, exit.y)]

							for y in [@levelY(from, exit.y)..@levelY(to, entrance.y)]
								path.push [middleX, y]

							for x in [@levelX(to, entrance.x+1)...middleX]
								path.push [x, @levelY(to, entrance.y)]


					for [tileX, tileY] in path
						@tiles[tileX][tileY] = "."

						for neighbourX in [tileX-1..tileX+1]
							for neighbourY in [tileY-1..tileY+1]
								continue if neighbourX < 0 or
										neighbourX >= LEVEL_WIDTH * (ROOM_WIDTH + 1) or
										neighbourY < 0 or
										neighbourY >= LEVEL_HEIGHT * (ROOM_HEIGHT + 1)

								existingTile = @existingTile neighbourX, neighbourY
								if (not existingTile) or (existingTile is " ")
									@tiles[neighbourX][neighbourY] = "W"

			existingTile: (tileX, tileY) ->
				tile = null

				roomX = Math.floor(tileX / (ROOM_WIDTH + 1))
				roomY = Math.floor(tileY / (ROOM_HEIGHT + 1))
				if @rooms[roomX] and @rooms[roomX][roomY]
					room		= @rooms[roomX][roomY]
					roomTileX	= tileX - (roomX * (ROOM_WIDTH + 1))
					roomTileY	= tileY - (roomY * (ROOM_HEIGHT + 1))

					if room.tiles[roomTileX] and room.tiles[roomTileX][roomTileY]
						tile = room.tiles[roomTileX][roomTileY]

				if not tile or tile is " "
					if @tiles[tileX] and @tiles[tileX][tileY]
						tile = @tiles[tileX][tileY]

				return tile

				return till


			levelX: (room, tileX) ->
				tileX + room.xIndex * (ROOM_WIDTH + 1)

			levelY: (room, tileY) ->
				tileY + room.yIndex * (ROOM_HEIGHT + 1)


		class Reifier
			reifyEntity: (tileX, tileY, tile) ->
				x = tileX * TILE_WIDTH
				y = tileY * TILE_HEIGHT

				switch tile
					when "wall"
						new staticEntities.Wall x, y
					when "W"
						new staticEntities.Wall x, y
					when "floor"
						new staticEntities.Floor x, y
					when "."
						new staticEntities.Floor x, y
					when "silverfish"
						new entities.Silverfish x, y
					when "barrel"
						new entities.Barrel x, y

			addRoomOffset: (room, pos) ->
				pos.x += room.xIndex * (ROOM_WIDTH + 1) * TILE_WIDTH
				pos.y += room.yIndex * (ROOM_HEIGHT + 1) * TILE_HEIGHT
				return pos

			reify: (level) ->
				es = []

				level.rooms.each (roomX, roomY, room) =>
					return unless room

					room.tiles.each (tileX, tileY, tile) =>
						entity = @reifyEntity tileX, tileY, tile
						if entity
							@addRoomOffset room, entity
							es.push entity

					numberOfEnemies = random.intInRange(2, 5)
					for {x: tileX, y: tileY} in room.enemies numberOfEnemies
						enemy = new entities.Silverfish(
							(tileX + 0.5) * TILE_WIDTH,
							(tileY + 0.5) * TILE_HEIGHT
						)
						@addRoomOffset room, enemy
						es.push enemy

				level.tiles.each (tileX, tileY, tile) =>
					entity = @reifyEntity tileX, tileY, tile
					if entity
						es.push entity

				return es

		return {
			Level: Level
			Reifier: Reifier
		}
