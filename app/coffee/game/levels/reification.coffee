define ['game/entities', 'game/entities/statics', 'game/consts', 'core/util'],
	(entities, staticEntities, consts, util) ->
		ns = {}

		TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
		ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
		LEVEL_WIDTH	= LEVEL_HEIGHT	= consts.LEVEL_WIDTH

		random = util.random

		class ns.Reifier
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
					for {x: tileX, y: tileY} in room.enemyPositions numberOfEnemies
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

		return ns
