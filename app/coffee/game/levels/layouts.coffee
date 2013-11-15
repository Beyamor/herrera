define ['game/consts', 'core/util'],
	(consts, util) ->
		ns = {}

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

			return {
				rooms: rooms
				connections: connections
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
