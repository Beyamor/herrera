define ['core/util', 'game/consts', 'game/rooms', 'game/levels/layouts'],
	(util, consts, rooms, layouts) ->
		ns = {}

		StartRoom	= rooms.StartRoom
		RegularRoom	= rooms.RegularRoom
		EndRoom		= rooms.EndRoom

		TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
		ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
		LEVEL_WIDTH	= LEVEL_HEIGHT	= consts.LEVEL_WIDTH

		random = util.random

		class ns.Level
			constructor: ->
				@rooms = util.array2d LEVEL_WIDTH, LEVEL_HEIGHT

				tileWidth	= LEVEL_WIDTH * (ROOM_WIDTH + 1)
				tileHeight	= LEVEL_HEIGHT * (ROOM_HEIGHT + 1)
				@tiles		= util.array2d tileWidth * tileHeight

				@construct()

			construct: ->
				layout = layouts.createLayout()

				@start = layout.start

				# create rooms
				@rooms = util.array2d LEVEL_WIDTH, LEVEL_HEIGHT, (i, j) ->
					room = layout.rooms[i][j]
					if room?
						roomClass = switch room.type
							when "start"	then StartRoom
							when "regular"	then RegularRoom
							when "end"	then EndRoom

						return new roomClass i, j

				# set connections between them
				@connections = []
				for {from: from, to: to} in layout.connections
					dx		= to.x - from.x
					dy		= to.y - from.y
					direction	= util.deltaToDirection dx, dy
					fromRoom	= @rooms[from.x][from.y]
					toRoom		= @rooms[to.x][to.y]

					fromRoom.addExit direction
					toRoom.addEntrance util.oppositeDirection direction

					@connections.push
						from: fromRoom
						to: toRoom
						direction: direction

				# finalize the rooms
				@rooms.each (_, _, room) ->
					room.finalize() if room and room.finalize?

				# and build the connections
				for {from: from, to: to, direction: direction} in @connections
                                        exit		= from.exits[direction]
                                        entrance        = to.entrance

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
		
		return ns
