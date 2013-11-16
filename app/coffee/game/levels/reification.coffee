define ['game/entities', 'game/entities/statics', 'game/consts', 'core/util'],
	(entities, staticEntities, consts, util) ->
		ns = {}

		TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
		ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
		LEVEL_WIDTH	= LEVEL_HEIGHT	= consts.LEVEL_WIDTH

		random = util.random

		class ns.Reifier
			reifyFloor: (x, y) ->
				new staticEntities.Floor x, y

			reifyWall: (x, y) ->
				new staticEntities.Wall x, y

			reifyEnemy: (x, y) ->
				new entities.Silverfish x, y

			addRoomOffset: (room, pos) ->
				pos.x += room.xIndex * (ROOM_WIDTH + 1) * TILE_WIDTH
				pos.y += room.yIndex * (ROOM_HEIGHT + 1) * TILE_HEIGHT
				return pos

			reify: (level) ->
				es = []

				level.rooms.each (roomX, roomY, room) =>
					return unless room

					numberOfEnemies = random.intInRange(2, 5)
					roomEntities = room.realize this,
								numberOfEnemies: numberOfEnemies
					es.push(e) for e in roomEntities


				# TODO add inter-level paths back in
				#level.tiles.each (tileX, tileY, tile) =>
				#	entity = @reifyEntity tileX, tileY, tile
				#	if entity
				#		es.push entity

				startRoom	= level.rooms[level.start.x][level.start.y]
				@player		= new entities.Player 100, 100
				es.push @player
				@addRoomOffset startRoom, @player

				return es

		return ns
