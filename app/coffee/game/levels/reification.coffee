define ['game/entities', 'game/entities/statics', 'game/consts', 'core/util', 'game/rooms'],
	(entities, staticEntities, consts, util, rooms) ->
		ns = {}

		TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
		ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
		LEVEL_WIDTH	= LEVEL_HEIGHT	= consts.LEVEL_WIDTH

		random	= util.random
		array2d	= util.array2d

		class ns.Reifier
			reifyFloor: (x, y, color) ->
				new staticEntities.Floor x, y, color

			reifyWall: (x, y) ->
				new staticEntities.Wall x, y

			reifyEnemy: (x, y) ->
				new entities.Silverfish x, y

			reifyWallOrFloor: (x, y, type, color) ->
				if type is "." or type is "floor"
					return @reifyFloor x, y, color
				else if type is "W" or type is "wall"
					return @reifyWall x, y

			reifyPortal: (x, y) ->
				new staticEntities.Portal x, y

			addRoomOffset: (room, pos) ->
				pos.x += room.xIndex * (ROOM_WIDTH + 1) * TILE_WIDTH
				pos.y += room.yIndex * (ROOM_HEIGHT + 1) * TILE_HEIGHT
				return pos

			reify: (level) ->
				es = []

				array2d.each level.rooms, (roomX, roomY, room) =>
					return unless room

					numberOfEnemies = random.intInRange(2, 4)
					roomEntities = rooms.realize room, this,
								numberOfEnemies: numberOfEnemies
					es.push(e) for e in roomEntities

				array2d.each level.tiles, (tileX, tileY, type) =>
					entity = @reifyWallOrFloor tileX * TILE_WIDTH, tileY * TILE_HEIGHT, type
					if entity
						es.push entity

				startRoom	= level.rooms[level.start.x][level.start.y]
				@player		= new entities.Player 100, 100
				es.push @player
				@addRoomOffset startRoom, @player

				return es

		return ns
