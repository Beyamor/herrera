define ['game/consts', 'core/util'],
	(consts, util) ->
		ns = {}

		TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
		ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
		LEVEL_WIDTH	= LEVEL_HEIGHT	= consts.LEVEL_WIDTH

		MAX_SUPERROOM_SIZE = 3

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
				isLastRoom	= (mainPathLength == desiredMainPathLength - 1)
				type		= if isLastRoom then "end" else "regular"
				room		= addToMainPath candidate.x, candidate.y, type

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

			superRooms			= []
			unmergedRooms			= []
			desiredNumberOfSuperRooms	= 0 #random.any [0, 1, 1, 1, 2]
			rooms.each (i, j, room) =>
				if room and room.type is "regular"
					unmergedRooms.push({x: i, y: j})

			# okay, let's see
			# while we have umerged rooms
			while unmergedRooms.length > 0 and superRooms.length < desiredNumberOfSuperRooms

				# start building a superroom with one of them
				initialIndex	= random.intInRange unmergedRooms.length
				initialRoom	= unmergedRooms[initialIndex]
				roomsToMerge	= [initialRoom]
				superRoom	= []
				superRooms.push superRoom
				unmergedRooms.remove initialRoom

				# now, while we've got rooms to add to the superroom
				while roomsToMerge.length > 0 and superRoom.length < MAX_SUPERROOM_SIZE
					index	= random.intInRange roomsToMerge.length
					room	= roomsToMerge[index]
					roomsToMerge.remove room

					# add a room (noting it as merged)
					rooms[room.x][room.y].type = "superroom"
					superRoom.push(room)
					unmergedRooms = _.filter unmergedRooms, (unmergedRoom) ->
						unmergedRoom.x isnt room.x or unmergedRoom.y isnt room.y

					# then add other reachable rooms
					for direction in util.DIRECTIONS
						[dx, dy]	= util.directionToDelta direction
						neighbourX	= room.x + dx
						neighbourY	= room.y + dy

						continue if neighbourX < 0 or neighbourY < 0 or
								neighbourX >= LEVEL_WIDTH or neighbourY >= LEVEL_HEIGHT

						# we only want add reachable rooms
						# (connected from or to)
						reachable = false
						for {from: from, to: to} in connections
							reachable or= from.x is room.x and from.y is room.y and
									to.x is neighbourX and to.y is neighbourY
							reachable or= to.x is room.x and to.y is room.y and
									from.x is neighbourX and from.y is neighbourY
						continue unless reachable

						neighbour = rooms[neighbourX][neighbourY]

						continue unless neighbour
						continue unless neighbour.type is "regular"

						alreadyInMergeList = false
						for {x: x, y: y} in roomsToMerge
							if x is neighbourX and y is neighbourY
								alreadyInMergeList = true
								break
						continue if alreadyInMergeList

						alreadyInSuperRoom = false
						for existingSuperRoom in superRooms
							for {x: x, y: y} in existingSuperRoom
								if x is neighbourX and y is neighbourY
									alreadyInSuperRoom = true
									break
							break if alreadyInSuperRoom
						continue if alreadyInSuperRoom


						roomsToMerge.push {x: neighbourX, y: neighbourY}

			return {
				rooms: rooms
				connections: connections
				superRooms: superRooms
				start: {
					x: startX
					y: startY
				}
			}

		ns.createLayout = ->
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

		return ns
