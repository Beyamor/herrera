define ['game/entities', 'game/entities/statics', 'core/util', 'game/consts', 'game/rooms'],
	(entities, staticEntities, util, consts, rooms) ->
		StartRoom	= rooms.StartRoom
		RegularRoom	= rooms.RegularRoom

		TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
		ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
		LEVEL_WIDTH	= LEVEL_HEIGHT	= consts.LEVEL_WIDTH

		random = util.random

		createLayout = ->
			MAX_MAIN_PATH_LENGTH	= 3

			rooms = util.array2d LEVEL_WIDTH, LEVEL_HEIGHT

			mainPathLength	= 0
			lastRoom	= null

			isFree = (x, y) ->
				return false if x < 0 or x >= LEVEL_WIDTH or
						y < 0 or y >= LEVEL_HEIGHT

				return rooms[x][y] is null

			addToMainPath = (x, y, type) ->
				throw new Error "#{x}, #{y} isn't free" unless isFree x, y
				rooms[x][y]	= {type: "start", exits: []}
				lastRoom	= {x: x, y: y}
				++mainPathLength

			startX = random.intInRange LEVEL_WIDTH
			startY = random.intInRange LEVEL_HEIGHT
			addToMainPath startX, startY, "start"

			return {
				rooms: rooms
				start: {
					x: startX
					y: startY
				}
			}

		class Level
			constructor: ->
				@rooms = util.array2d LEVEL_WIDTH, LEVEL_HEIGHT
				@rooms[0][0] = new StartRoom 0, 0

				tileWidth	= LEVEL_WIDTH * (ROOM_WIDTH + 1)
				tileHeight	= LEVEL_HEIGHT * (ROOM_HEIGHT + 1)
				@tiles		= util.array2d tileWidth * tileHeight

				@construct()

			construct: ->
				layout = createLayout()

				@start = layout.start

				@rooms = util.array2d LEVEL_WIDTH, LEVEL_HEIGHT, (i, j) ->
					room = layout.rooms[i][j]
					if room?
						roomClass = switch room.type
							when "start"
								StartRoom

						return new roomClass i, j
						

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

				startRoom	= level.rooms[level.start.x][level.start.y]
				@player		= new entities.Player 100, 100
				es.push @player
				@addRoomOffset startRoom, @player

				return es

		return {
			Level: Level
			Reifier: Reifier
		}
