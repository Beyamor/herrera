define ['game/entities', 'game/entities/statics', 'core/util', 'game/consts', 'game/rooms'],
	(entities, staticEntities, util, consts, rooms) ->
		StartRoom	= rooms.StartRoom
		RegularRoom	= rooms.RegularRoom

		TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
		ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
		LEVEL_WIDTH	= LEVEL_HEIGHT	= consts.LEVEL_WIDTH

		random = util.random

		tryCreatingLayout = ({desiredMainPathLength:	desiredMainPathLength, \
					desiredExtraRooms:	desiredExtraRooms}) ->

			rooms		= util.array2d LEVEL_WIDTH, LEVEL_HEIGHT
			connections	= []

			mainPathLength		= 0
			extraRooms		= 0
			extraRoomExtensions	= []
			previousRoom		= null
			previousDirection	= null

			isFree = (x, y) ->
				return false if x < 0 or x >= LEVEL_WIDTH or
						y < 0 or y >= LEVEL_HEIGHT

				return rooms[x][y] is null

			addToMainPath = (x, y, type) ->
				throw new Error "#{x}, #{y} isn't free" unless isFree x, y

				nextRoom = {
					x: x
					y: y
					type: type
				}
				rooms[x][y] = nextRoom

				if previousRoom?
					connections.push
						from: previousRoom
						to: nextRoom

				previousRoom = nextRoom
				++mainPathLength

				return nextRoom

			startX = random.intInRange LEVEL_WIDTH
			startY = random.intInRange LEVEL_HEIGHT
			addToMainPath startX, startY, "start"

			while mainPathLength < desiredMainPathLength

				candidates = []
				for direction in util.DIRECTIONS
					[dx, dy]	= util.directionToDelta direction
					nextX		=  previousRoom.x + dx
					nextY		=  previousRoom.y + dy

					if isFree nextX, nextY
						candidates.push
							x: nextX
							y: nextY

				throw new Error "No candidates" if candidates.length is 0

				candidate	= random.any candidates
				room		= addToMainPath candidate.x, candidate.y, "regular"

				isLastRoom = (mainPathLength == desiredMainPathLength)
				unless isLastRoom
					extraRoomExtensions.push room

			while extraRooms < desiredExtraRooms
				candidates = []
				for room in extraRoomExtensions
					for direction in util.DIRECTIONS
						[dx, dy]	= util.directionToDelta direction
						nextX		= room.x + dx
						nextY		= room.y + dy

						if isFree nextX, nextY
							candidates.push  [nextX, nextY, room]

				# could throw but really, who cares
				break if candidates.length is 0

				[nextX, nextY, fromRoom] = random.any candidates
				rooms[nextX][nextY] = toRoom = {
					x: nextX
					y: nextY
					type: "regular"
				}

				connections.push from: fromRoom, to: toRoom
				extraRoomExtensions.push toRoom
				++extraRooms

			return {
				rooms: rooms
				connections: connections
				start: {
					x: startX
					y: startY
				}
			}

		createLayout = ->
			attempts	= 0
			maxAttempts	= 10

			while true
				try
					return tryCreatingLayout
						desiredMainPathLength: random.intInRange 8, 10
						desiredExtraRooms: random.intInRange 3, 5

				catch error
					++attempts

					if attempts >= maxAttempts
						alert "Whoa, couldn't create a level"
						throw new Error "Couldn't create layout"

		class Level
			constructor: ->
				@rooms = util.array2d LEVEL_WIDTH, LEVEL_HEIGHT

				tileWidth	= LEVEL_WIDTH * (ROOM_WIDTH + 1)
				tileHeight	= LEVEL_HEIGHT * (ROOM_HEIGHT + 1)
				@tiles		= util.array2d tileWidth * tileHeight

				@construct()

			construct: ->
				layout = createLayout()

				@start = layout.start

				# create rooms
				@rooms = util.array2d LEVEL_WIDTH, LEVEL_HEIGHT, (i, j) ->
					room = layout.rooms[i][j]
					if room?
						roomClass = switch room.type
							when "start"	then StartRoom
							when "regular"	then RegularRoom

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
