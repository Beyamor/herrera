define ['core/util', 'game/consts', 'game/rooms', 'game/levels/layouts', "game/rooms/super-rooms"],
	(util, consts, rooms, layouts, superRooms) ->
		ns = {}

		StartRoom			= rooms.StartRoom
		PrefabRoom			= rooms.PrefabRoom
		EndRoom				= rooms.EndRoom
		OrganicLayout			= superRooms.OrganicLayout
		SuperRoomSection		= rooms.SuperRoomSection

		TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
		ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
		LEVEL_WIDTH	= LEVEL_HEIGHT	= consts.LEVEL_WIDTH

		random = util.random

		levelX = (room, tileX) ->
			tileX + room.xIndex * (ROOM_WIDTH + 1)

		levelY = (room, tileY) ->
			tileY + room.yIndex * (ROOM_HEIGHT + 1)

		getExistingTile = ({rooms: rooms, tiles: tiles}, tileX, tileY) ->
				tile = null

				roomX = Math.floor(tileX / (ROOM_WIDTH + 1))
				roomY = Math.floor(tileY / (ROOM_HEIGHT + 1))
				if rooms[roomX] and rooms[roomX][roomY]
					room		= rooms[roomX][roomY]
					roomTileX	= tileX - (roomX * (ROOM_WIDTH + 1))
					roomTileY	= tileY - (roomY * (ROOM_HEIGHT + 1))

					if room.tiles[roomTileX] and room.tiles[roomTileX][roomTileY]
						tile = room.tiles[roomTileX][roomTileY]

				if not tile or tile is " "
					if tiles[tileX] and tiles[tileX][tileY]
						tile = tiles[tileX][tileY]

				return tile

		ns.construct = (layout) ->
			tileWidth	= LEVEL_WIDTH * (ROOM_WIDTH + 1)
			tileHeight	= LEVEL_HEIGHT * (ROOM_HEIGHT + 1)

			level = {
				tiles:	util.array2d tileWidth, tileHeight
				start: layout.start
			}

			# create rooms
			level.rooms = util.array2d LEVEL_WIDTH, LEVEL_HEIGHT, (i, j) ->
				room = layout.rooms[i][j]
				if room?
					if room.type is 'regular' then room.type = 'prefab'
					rooms.create room.type, i, j

			# create superrooms
			for superRoomList in layout.superRooms
				sections = (level.rooms[x][y] for {x: x, y: y} in superRoomList)
				superRoom = new OrganicLayout sections

			# set connections between them
			connections = []
			for {from: from, to: to} in layout.connections
				dx		= to.x - from.x
				dy		= to.y - from.y
				direction	= util.deltaToDirection dx, dy
				fromRoom	= level.rooms[from.x][from.y]
				toRoom		= level.rooms[to.x][to.y]

				inSameSuperRoom	= fromRoom.superRoom? and toRoom.superRoom? and
							fromRoom.superRoom is toRoom.superRoom

				unless inSameSuperRoom
					rooms.addExit fromRoom, direction
					rooms.addEntrance toRoom, util.oppositeDirection(direction)

					connections.push
						from: fromRoom
						to: toRoom
						direction: direction

			# finalize the rooms
			level.rooms.each (_, _, room) ->
				rooms.finalize room if room?

			# and build the connections
			for {from: from, to: to, direction: direction} in connections
				exit		= from.exits[direction]
				entrance	= to.entrance
				
				path = []
				switch direction
					when "south"
						middleY = levelY(to, -1)

						for y in [levelY(from, exit.y+1)...middleY]
							path.push [levelX(from, exit.x), y]

						for x in [levelX(from, exit.x)..levelX(to, entrance.x)]
							path.push [x, middleY]

						for y in [levelY(to, entrance.y-1)...middleY]
							path.push [levelX(to, entrance.x), y]

					when "north"
						middleY = levelY(from, -1)

						for y in [levelY(from, exit.y-1)...middleY]
							path.push [levelX(from, exit.x), y]

						for x in [levelX(from, exit.x)..levelX(to, entrance.x)]
							path.push [x, middleY]

						for y in [levelY(to, entrance.y+1)...middleY]
							path.push [levelX(to, entrance.x), y]

					when "east"
						middleX = levelX(to, -1)

						for x in [levelX(from, exit.x+1)...middleX]
							path.push [x, levelY(from, exit.y)]

						for y in [levelY(from, exit.y)..levelY(to, entrance.y)]
							path.push [middleX, y]

						for x in [levelX(to, entrance.x-1)...middleX]
							path.push [x, levelY(to, entrance.y)]

					when "west"
						middleX = levelX(from, -1)

						for x in [levelX(from, exit.x-1)...middleX]
							path.push [x, levelY(from, exit.y)]

						for y in [levelY(from, exit.y)..levelY(to, entrance.y)]
							path.push [middleX, y]

						for x in [levelX(to, entrance.x+1)...middleX]
							path.push [x, levelY(to, entrance.y)]


				for [tileX, tileY] in path
					level.tiles[tileX][tileY] = "."

					for neighbourX in [tileX-1..tileX+1]
						for neighbourY in [tileY-1..tileY+1]
							continue if neighbourX < 0 or
									neighbourX >= LEVEL_WIDTH * (ROOM_WIDTH + 1) or
									neighbourY < 0 or
									neighbourY >= LEVEL_HEIGHT * (ROOM_HEIGHT + 1)

							existingTile = getExistingTile level, neighbourX, neighbourY
							if (not existingTile) or (existingTile is " ")
								level.tiles[neighbourX][neighbourY] = "W"
			console.log level
			return level

		return ns
